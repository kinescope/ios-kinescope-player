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

    // MARK: - Initialisation

    init(apiKey: String,
         videoPathsStorage: KinescopeVideoPathsStorage) {
        self.apiKey = apiKey
        self.videoPathsStorage = videoPathsStorage
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

    func enqeueDownload(assetId: String) {
        preconditionFailure("Implement")
    }

    func deqeueDownload(assetId: String) {
        preconditionFailure("Implement")
    }

    func add(delegate: KinescopeDownloadableDelegate) {
        delegates.append(delegate)
    }

    func remove(delegate: KinescopeDownloadableDelegate) {
        if let index = delegates.firstIndex(where: { delegate === $0 }) {
            delegates.remove(at: index)
        }
    }

}
