//
//  AssetDownloader.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//

import Foundation

// MARK: - KinescopeAssetDownloadable

class AssetDownloader: KinescopeAssetDownloadable {

    // MARK: - Properties

    private var delegates: [KinescopeAssetDownloadableDelegate] = []

    private let assetPathsStorage: KinescopeAssetPathsStorage
    private var assetService: AssetService

    // MARK: - Initialisation

    init(assetPathsStorage: KinescopeAssetPathsStorage,
         assetService: AssetService) {
        self.assetPathsStorage = assetPathsStorage
        self.assetService = assetService
        self.assetService.delegate = self
    }

    // MARK: - KinescopeDownloadable

    func downlaodedAssetsList() -> [String] {
        return assetPathsStorage.fetchAssetIds()
    }

    @discardableResult
    func delete(assetId: String) -> Bool {
        guard let assetUrl = assetPathsStorage.readVideoUrl(by: assetId) else {
            return false
        }
        do {
            try FileManager.default.removeItem(at: assetUrl)
            assetPathsStorage.deleteVideoUrl(by: assetId)
            return true
        } catch {
            Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.storage)
            return false
        }
    }

    func clear() {
        for assetId in downlaodedAssetsList() {
            delete(assetId: assetId)
        }
    }

    func getPath(by assetId: String) -> URL? {
        return assetPathsStorage.readVideoUrl(by: assetId)
    }

    func enqueueDownload(assetId: String) {
        assetService.enqueueDownload(assetId: assetId)
    }

    func pauseDownload(assetId: String) {
        assetService.pauseDownload(assetId: assetId)
    }

    func resumeDownload(assetId: String) {
        assetService.resumeDownload(assetId: assetId)
    }

    func dequeueDownload(assetId: String) {
        assetService.dequeueDownload(assetId: assetId)
    }

    func add(delegate: KinescopeAssetDownloadableDelegate) {
        delegates.append(delegate)
    }

    func remove(delegate: KinescopeAssetDownloadableDelegate) {
        if let index = delegates.firstIndex(where: { delegate === $0 }) {
            delegates.remove(at: index)
        }
    }

    func restore() {
        assetService.restore()
    }

}

// MARK: - AssetServiceDelegate

extension AssetDownloader: AssetServiceDelegate {

    func downloadProgress(assetId: String, progress: Double) {
        delegates.forEach {
            $0.kinescopeDownloadProgress(assetId: assetId, progress: progress)
        }
    }

    func downloadError(assetId: String, error: KinescopeDownloadError) {
        delegates.forEach {
            $0.kinescopeDownloadError(assetId: assetId, error: error)
        }
    }

    func downloadComplete(assetId: String, path: String) {
        assetPathsStorage.saveAsset(relativeUrl: path, id: assetId)
        delegates.forEach {
            $0.kinescopeDownloadComplete(assetId: assetId)
        }
    }

}
