//
//  DataProtectionResourceDelegateHandler.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 21.02.2024.
//

import AVFoundation

/// `AVAssetResourceLoaderDelegate` implementation to handle the DRM protected content.
final class DataProtectionResourceDelegateHandler: NSObject, DataProtectionHandler {

    // MARK: - Private Properties

    private let videoId: String
    private let service: DataProtectionService

    private let executionQueue = DispatchQueue(label: "io.kinescope.fairplay")

    // MARK: - Lifecycle

    init(videoId: String, service: DataProtectionService) {
        self.videoId = videoId
        self.service = service
        super.init()
    }

    // MARK: - DataProtectionHandler

    func bind(with asset: AVURLAsset) {
        asset.resourceLoader.setDelegate(self, queue: executionQueue)
    }

}

// MARK: - AVContentKeySessionDelegate

extension DataProtectionResourceDelegateHandler: AVAssetResourceLoaderDelegate {

    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        Kinescope.shared.logger?.log(message: "AVPlayer trying to play protected data", level: KinescopeLoggerLevel.drm)

        guard let contentIdentifierData = parseContentId(loadingRequest) else {
            handleError(.unableToReadContentId, for: loadingRequest)
            return false
        }

        service.getCert(for: videoId) { [weak self] result in
            guard let self else {
                return
            }

            switch result {
            case .success(let applicationCertificate):
                var spcData: Data?
                do {
                    spcData = try loadingRequest.streamingContentKeyRequestData(forApp: applicationCertificate, contentIdentifier: contentIdentifierData)
                } catch let error {
                    handleError(.contentKeyRequestFailed(error), for: loadingRequest)
                }

                handleCompletion(with: spcData, for: loadingRequest)
            case .failure(let error):
                handleError(.certificateRequetFailed(error), for: loadingRequest)
            }
        }
        return true
    }

}


// MARK: - Private

private extension DataProtectionResourceDelegateHandler {

    func parseContentId(_ loadingRequest: AVAssetResourceLoadingRequest) -> Data? {
        guard let contentIdentifier = loadingRequest.request.url?.absoluteString,
              let contentData = contentIdentifier.replacingOccurrences(of: "skd://", with: "").data(using: .utf8) else {
            return nil
        }
        return contentData
    }

    func handleError(_ error: KinescopeDataProtectionError, for loadingRequest: AVAssetResourceLoadingRequest) {
        Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.drm)
        loadingRequest.finishLoading(with: error)
    }

    func handleCompletion(with spcData: Data?,
                          for loadingRequest: AVAssetResourceLoadingRequest) {

        guard let spc = spcData?.base64EncodedString(),
              let dataRequest = loadingRequest.dataRequest else {
            handleError(.cannotEncodeSPC, for: loadingRequest)
            return
        }

        service.getContentKey(for: videoId, body: .init(spc: spc)) { [weak self] result in
            switch result {
            case .success(let response):
                guard let ckcData = try? Data(base64Encoded: response.ckc) else {
                    self?.handleError(.cannotDecodeCKC, for: loadingRequest)
                    return
                }
                Kinescope.shared.logger?.log(message: "DRM Content Key received and sended to AVPlayer", level: KinescopeLoggerLevel.drm)
                dataRequest.respond(with: ckcData)
                loadingRequest.finishLoading()
            case .failure(let error):
                self?.handleError(.registraionRequestFailed(error), for: loadingRequest)
            }
        }
    }

}
