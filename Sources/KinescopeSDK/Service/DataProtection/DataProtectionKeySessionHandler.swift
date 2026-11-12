//
//  DataProtectionKeySessionHandler.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 21.02.2024.
//

import AVFoundation

// `AVContentKeySessionDelegate` implementation to handle the DRM protected content.
@available(iOS 11, *)
final class DataProtectionKeySessionHandler: NSObject, DataProtectionHandler {

    // MARK: - Private Properties
    
    private let video: KinescopeVideo
    private let service: DataProtectionService
    /// Download asks for a key that can be replayed without the license server.
    private let persistable: Bool
    private lazy var session: AVContentKeySession = .init(keySystem: .fairPlayStreaming)

    private let executionQueue = DispatchQueue(label: "io.kinescope.fairplay")
    private let keyStateLock = NSLock()
    private var persistentKeyArmed = false
    private var persistentKeyResult: Result<Void, Error>?
    private var persistentKeyWaiter: ((Result<Void, Error>) -> Void)?

    /// Download completion can arrive while the license request is still running.
    /// The caller is resumed on whichever queue finishes last.
    func whenPersistentKeyResolved(_ body: @escaping (Result<Void, Error>) -> Void) {
        keyStateLock.lock()
        let armed = persistentKeyArmed
        let result = persistentKeyResult
        if armed, result == nil {
            persistentKeyWaiter = body
            keyStateLock.unlock()
            return
        }
        keyStateLock.unlock()
        if let result {
            body(result)
        } else {
            body(.failure(PersistentKeyUnavailable()))
        }
    }

    var hasOfflineKey: Bool {
        PersistentContentKeyStore.key(for: video.id) != nil
    }

    // MARK: - Lifecycle

    init(video: KinescopeVideo, service: DataProtectionService, persistable: Bool = false) {
        self.video = video
        self.service = service
        self.persistable = persistable
        super.init()
    }

    // MARK: - DataProtectionHandler

    /// Creates the content-key session without an asset. Call this before the background
    /// download session is reconnected, then `bind(with:)` once the task's asset exists.
    func prepareSession() {
        session.setDelegate(self, queue: executionQueue)
    }

    func bind(with asset: AVURLAsset) {
        session.setDelegate(self, queue: executionQueue)
        session.addContentKeyRecipient(asset)
    }

}

// MARK: - AVContentKeySessionDelegate

@available(iOS 11, *)
extension DataProtectionKeySessionHandler: AVContentKeySessionDelegate {

    func contentKeySession(_ session: AVContentKeySession, didProvide keyRequest: AVContentKeyRequest) {
        Kinescope.shared.logger?.log(message: "AVPlayer trying to play protected data", level: KinescopeLoggerLevel.drm)

        // A persistent key is not a streaming CKC. Answering the plain request with it
        // leaves the item in .waiting forever. Upgrade first, then answer the persistable request.
        if persistable || PersistentContentKeyStore.exists(for: video.id) {
            if persistable {
                armPersistentKeyRequest()
            }
            do {
                try keyRequest.respondByRequestingPersistableContentKeyRequestAndReturnError()
            } catch {
                if persistable {
                    resolvePersistentKey(.failure(error))
                }
                handleError(.contentKeyRequestFailed(error), for: keyRequest)
            }
            return
        }

        requestOnlineKey(for: keyRequest)
    }

    func contentKeySession(_ session: AVContentKeySession, didProvide keyRequest: AVPersistableContentKeyRequest) {
        Kinescope.shared.logger?.log(message: "Persistable FairPlay key requested", level: KinescopeLoggerLevel.drm)
        if answer(keyRequest, withStoredKey: true) {
            resolvePersistentKey(.success(()))
            return
        }
        guard persistable else {
            handleError(.contentKeyRequestFailed(nil), for: keyRequest)
            return
        }
        armPersistentKeyRequest()
        requestOnlineKey(for: keyRequest, persist: true)
    }

    /// Renew an expired offline lease. A missing key still has to go through the license server.
    func contentKeySession(_ session: AVContentKeySession,
                           shouldRetry keyRequest: AVContentKeyRequest,
                           reason retryReason: AVContentKeyRequest.RetryReason) -> Bool {
        switch retryReason {
        case .timedOut, .receivedResponseWithExpiredLease, .receivedObsoleteContentKey:
            return true
        default:
            return false
        }
    }

}


// MARK: - Private

@available(iOS 11, *)
private extension DataProtectionKeySessionHandler {

    @discardableResult
    func answer(_ keyRequest: AVContentKeyRequest, withStoredKey: Bool) -> Bool {
        guard withStoredKey, let stored = PersistentContentKeyStore.key(for: video.id) else {
            return false
        }
        keyRequest.processContentKeyResponse(AVContentKeyResponse(fairPlayStreamingKeyResponseData: stored))
        return true
    }

    func parseContentId(_ keyRequest: AVContentKeyRequest) -> Data? {
        guard let contentIdentifier = keyRequest.identifier as? String,
              let contentData = contentIdentifier.replacingOccurrences(of: "skd://", with: "").data(using: .utf8) else {
            return nil
        }
        return contentData
    }

    func handleError(_ error: KinescopeDataProtectionError, for keyRequest: AVContentKeyRequest) {
        Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.drm)
        if persistable {
            resolvePersistentKey(.failure(error))
        }
        keyRequest.processContentKeyResponseError(error)
    }

    func requestOnlineKey(for keyRequest: AVContentKeyRequest, persist: Bool = false) {
        let contentIdentifierData: Data? = parseContentId(keyRequest)
            ?? video.id.data(using: .utf8)
        guard let contentIdentifierData else {
            handleError(.unableToReadContentId, for: keyRequest)
            return
        }

        service.getCert(for: video) { [weak self] result in
            guard let self else {
                return
            }

            switch result {
            case .success(let applicationCertificate):
                keyRequest.makeStreamingContentKeyRequestData(
                    forApp: applicationCertificate,
                    contentIdentifier: contentIdentifierData,
                    options: [AVContentKeyRequestProtocolVersionsKey: [1]],
                    completionHandler: handleCompletion(for: keyRequest, persist: persist)
                )
            case .failure(let error):
                handleError(.certificateRequetFailed(error), for: keyRequest)
            }
        }
    }

    func handleCompletion(for keyRequest: AVContentKeyRequest, persist: Bool) -> (Data?, Error?) -> Void {
        { [weak self] (spcData: Data?, error: Error?) in
            guard error == nil else {
                self?.handleError(.contentKeyRequestFailed(error), for: keyRequest)
                return
            }

            guard let video = self?.video,
                    let spc = spcData?.base64EncodedString() else {
                self?.handleError(.cannotEncodeSPC, for: keyRequest)
                return
            }

            self?.service.getContentKey(for: video, body: .init(spc: spc)) { [weak self] result in
                switch result {
                case .success(let response):
                    guard let ckcData = Data(base64Encoded: response.ckc) else {
                        self?.handleError(.cannotDecodeCKC, for: keyRequest)
                        return
                    }
                    self?.finish(keyRequest: keyRequest, ckcData: ckcData, persist: persist)
                case .failure(let error):
                    self?.handleError(.registraionRequestFailed(error), for: keyRequest)
                }
            }
        }
    }

    func finish(keyRequest: AVContentKeyRequest, ckcData: Data, persist: Bool) {
        var keyData = ckcData
        if persist, let request = keyRequest as? AVPersistableContentKeyRequest {
            do {
                keyData = try request.persistableContentKey(fromKeyVendorResponse: ckcData, options: nil)
                PersistentContentKeyStore.save(keyData, for: video.id)
                resolvePersistentKey(.success(()))
            } catch {
                Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.drm)
                resolvePersistentKey(.failure(error))
                keyRequest.processContentKeyResponseError(error)
                return
            }
        }
        Kinescope.shared.logger?.log(message: "DRM Content Key received and sended to AVPlayer",
                                     level: KinescopeLoggerLevel.drm)
        keyRequest.processContentKeyResponse(AVContentKeyResponse(fairPlayStreamingKeyResponseData: keyData))
    }

    func armPersistentKeyRequest() {
        keyStateLock.lock()
        persistentKeyArmed = true
        keyStateLock.unlock()
    }

    func resolvePersistentKey(_ result: Result<Void, Error>) {
        keyStateLock.lock()
        guard persistentKeyResult == nil else {
            keyStateLock.unlock()
            return
        }
        persistentKeyArmed = true
        persistentKeyResult = result
        let waiter = persistentKeyWaiter
        persistentKeyWaiter = nil
        keyStateLock.unlock()
        waiter?(result)
    }

}

private struct PersistentKeyUnavailable: LocalizedError {
    var errorDescription: String? {
        "The persistent FairPlay key was not requested."
    }
}
