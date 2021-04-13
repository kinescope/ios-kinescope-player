//
//  VideoDownloader.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 13.04.2021.
//

import Foundation

// MARK: - KinescopeVideoDownloadable

class VideoDownloader: KinescopeVideoDownloadable {

    // MARK: - Properties

    private var delegates: [KinescopeVideoDownloadableDelegate] = []

    private let videoPathsStorage: KinescopeVideoPathsStorage
    private var assetService: AssetService

    // MARK: - Initialisation

    init(videoPathsStorage: KinescopeVideoPathsStorage,
         assetService: AssetService) {
        self.videoPathsStorage = videoPathsStorage
        self.assetService = assetService
        self.assetService.delegate = self
    }

    // MARK: - KinescopeDownloadable

    func enqueueDownload(videoId: String, url: URL) {
        assetService.enqueueDownload(assetId: videoId, url: url)
    }

    func resumeDownload(videoId: String) {
        assetService.resumeDownload(assetId: videoId)
    }

    func pauseDownload(videoId: String) {
        assetService.pauseDownload(assetId: videoId)
    }

    func dequeueDownload(videoId: String) {
        assetService.dequeueDownload(assetId: videoId)
    }

    func downloadedList() -> [String] {
        return videoPathsStorage.fetchVideoIds()
    }

    func getLocation(by videoId: String) -> URL? {
        return videoPathsStorage.readVideoUrl(by: videoId)
    }

    @discardableResult
    func delete(videoId: String) -> Bool {
        guard let assetUrl = videoPathsStorage.readVideoUrl(by: videoId) else {
            return false
        }
        do {
            try FileManager.default.removeItem(at: assetUrl)
            videoPathsStorage.deleteVideoUrl(by: videoId)
            return true
        } catch {
            Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.storage)
            return false
        }
    }

    func clear() {
        for videoId in downloadedList() {
            delete(videoId: videoId)
        }
    }

    func add(delegate: KinescopeVideoDownloadableDelegate) {
        delegates.append(delegate)
    }

    func remove(delegate: KinescopeVideoDownloadableDelegate) {
        if let index = delegates.firstIndex(where: { delegate === $0 }) {
            delegates.remove(at: index)
        }
    }

    func restore() {
        assetService.restore()
    }

}

// MARK: - AssetServiceDelegate

extension VideoDownloader: AssetServiceDelegate {

    func downloadProgress(assetId: String, progress: Double) {
        delegates.forEach {
            $0.videoDownloadProgress(videoId: assetId, progress: progress)
        }
    }

    func downloadError(assetId: String, error: KinescopeDownloadError) {
        delegates.forEach {
            $0.videoDownloadError(videoId: assetId, error: error)
        }
    }

    func downloadComplete(assetId: String, path: String) {
        videoPathsStorage.saveVideo(relativeUrl: path, id: assetId)
        delegates.forEach {
            $0.videoDownloadComplete(videoId: assetId)
        }
    }

}
