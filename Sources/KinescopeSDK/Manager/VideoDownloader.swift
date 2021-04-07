//
//  VideoDownloader.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//

import Foundation

// MARK: - KinescopeDownloadable

class VideoDownloader: KinescopeDownloadable {

    // MARK: - Properties

    private var delegates: [KinescopeDownloadableDelegate] = []

    private let apiKey: String
    private let videoPathsStorage: KinescopeVideoPathsStorage
    private let assetService: AssetService

    // MARK: - Initialisation

    init(apiKey: String,
         videoPathsStorage: KinescopeVideoPathsStorage,
         assetService: AssetService) {
        self.apiKey = apiKey
        self.videoPathsStorage = videoPathsStorage
        self.assetService = assetService
    }

    // MARK: - Methods

    func downlaodedAssetsList() -> [String] {
        return videoPathsStorage.fetchVideoIds()
    }

    @discardableResult
    func delete(assetId: String) -> Bool {
        guard let assetUrl = videoPathsStorage.readVideoUrl(by: assetId) else {
            return false
        }
        do {
            try FileManager.default.removeItem(at: assetUrl)
            videoPathsStorage.deleteVideoUrl(by: assetId)
            return true
        } catch {
            Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.network)
            return false
        }
    }

    func clear() {
        for assetId in downlaodedAssetsList() {
            delete(assetId: assetId)
        }
    }

    func getPath(by assetId: String) -> URL? {
        return videoPathsStorage.readVideoUrl(by: assetId)
    }

    func enqeueDownload(assetId: String) {
        assetService.enqeueDownload(assetId: assetId)
    }

    func pauseDownload(assetId: String) {
        assetService.pauseDownload(assetId: assetId)
    }

    func resumeDownload(assetId: String) {
        assetService.resumeDownload(assetId: assetId)
    }

    func deqeueDownload(assetId: String) {
        assetService.deqeueDownload(assetId: assetId)
    }

    func add(delegate: KinescopeDownloadableDelegate) {
        delegates.append(delegate)
    }

    func remove(delegate: KinescopeDownloadableDelegate) {
        if let index = delegates.firstIndex(where: { delegate === $0 }) {
            delegates.remove(at: index)
        }
    }

    func restore() {
        preconditionFailure("Implement")
    }

}

extension VideoDownloader: AssetServiceDelegate {

    func downloadProgress(assetId: String, progress: Double) {
        delegates.forEach {
            $0.kinescopeDownloadProgress(assetId: assetId, progress: progress)
        }
    }

    func downloadError(assetId: String, error: Error) {
        delegates.forEach {
            $0.kinescopeDownloadError(assetId: assetId, error: .unknown(error))
        }
    }

    func downloadComplete(assetId: String, path: String) {
        videoPathsStorage.saveVideo(relativeUrl: path, id: assetId)
        delegates.forEach {
            $0.kinescopeDownloadComplete(assetId: assetId)
        }
    }

}
