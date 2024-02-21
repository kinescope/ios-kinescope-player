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
    
    private let videoId: String
    private let service: DataProtectionService
    private let session: AVContentKeySession = .init(keySystem: .fairPlayStreaming)

    // MARK: - Lifecycle

    init(videoId: String, service: DataProtectionService) {
        self.videoId = videoId
        self.service = service
        super.init()
    }

    // MARK: - DataProtectionHandler

    func bind(with asset: AVURLAsset) {
        session.addContentKeyRecipient(asset)
    }

}

// MARK: - AVContentKeySessionDelegate

@available(iOS 11, *)
extension DataProtectionKeySessionHandler: AVContentKeySessionDelegate {

    func contentKeySession(_ session: AVContentKeySession, didProvide keyRequest: AVContentKeyRequest) {
        Kinescope.shared.logger?.log(message: "AVPlayer trying to play protected data", level: KinescopeLoggerLevel.drm)

        guard let contentIdentifierData = parseContentId(keyRequest) else {
            handleError(.unableToReadContentId, for: keyRequest)
            return
        }
        
        service.getCert(for: videoId) { [weak self] result in
            guard let self else {
                return
            }

            switch result {
            case .success(let applicationCertificate):
                keyRequest.makeStreamingContentKeyRequestData(
                    forApp: applicationCertificate,
                    contentIdentifier: contentIdentifierData,
                    options: [AVContentKeyRequestProtocolVersionsKey: [1]],
                    completionHandler: handleCompletion(for: keyRequest)
                )
            case .failure(let error):
                handleError(.certificateRequetFailed(error), for: keyRequest)
            }
        }
    }

}


// MARK: - Private

@available(iOS 11, *)
private extension DataProtectionKeySessionHandler {

    func parseContentId(_ keyRequest: AVContentKeyRequest) -> Data? {
        guard let contentIdentifier = keyRequest.identifier as? String,
              let contentData = contentIdentifier.replacingOccurrences(of: "skd://", with: "").data(using: .utf8) else {
            return nil
        }
        return contentData
    }

    func handleError(_ error: KinescopeDataProtectionError, for keyRequest: AVContentKeyRequest) {
        Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.drm)
        keyRequest.processContentKeyResponseError(error)
    }

    func handleCompletion(for keyRequest: AVContentKeyRequest) -> (Data?, Error?) -> Void {
        { [weak self] (spcData: Data?, error: Error?) in
            guard error == nil else {
                self?.handleError(.contentKeyRequestFailed(error), for: keyRequest)
                return
            }

            guard let videoId = self?.videoId,
                    let spc = spcData?.base64EncodedString() else {
                self?.handleError(.cannotEncodeSPC, for: keyRequest)
                return
            }
            
            self?.service.getContentKey(for: videoId, body: .init(spc: spc)) { [weak self] result in
                switch result {
                case .success(let response):
                    guard let ckcData = try? Data(base64Encoded: response.ckc) else {
                        self?.handleError(.cannotDecodeCKC, for: keyRequest)
                        return
                    }
                    Kinescope.shared.logger?.log(message: "DRM Content Key received and sended to AVPlayer", level: KinescopeLoggerLevel.drm)
                    let keyResponse = AVContentKeyResponse(fairPlayStreamingKeyResponseData: ckcData)
                    keyRequest.processContentKeyResponse(keyResponse)
                case .failure(let error):
                    self?.handleError(.registraionRequestFailed(error), for: keyRequest)
                }
            }
        }
    }

}
