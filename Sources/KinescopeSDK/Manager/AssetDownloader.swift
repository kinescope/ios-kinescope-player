//
//  AssetDownloader.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//

import Foundation

// MARK: - KinescopeAssetDownloadable

class AssetDownloader: KinescopeAssetDownloadable {

    // MARK: - Constants

    private enum Constants {
        static let assetsDirectory = "KinescopeAssets"
    }

    // MARK: - Properties


    private let fileNamesStorage: KinescopeFileNamesStorage
    private let assetLinksService: AssetLinksService

    private var fileService: FileService
    private var delegates: [KinescopeAssetDownloadableDelegate] = []

    // MARK: - Initialisation

    init(fileService: FileService,
         assetLinksService: AssetLinksService,
         fileNamesStorage: KinescopeFileNamesStorage = FileNamesUDStorage(suffix: "assetNames")) {
        self.fileService = fileService
        self.assetLinksService = assetLinksService
        self.fileNamesStorage = fileNamesStorage
        self.fileService.delegate = self
    }

    // MARK: - KinescopeDownloadable

    func enqueueDownload(video: KinescopeVideo, asset: KinescopeVideoAsset) {
        // TODO: - Get downloading link from manifest
        let assetLink = assetLinksService.getAssetLink(by: video.id, asset: asset)

        if let url = URL(string: assetLink.link) {
            fileService.enqueueDownload(fileId: video.id, url: url)
            fileNamesStorage.saveFile(name: asset.name, id: video.id)
        } else {
            Kinescope.shared.logger?.log(message: "", level: KinescopeLoggerLevel.network)
        }
    }

    func pauseDownload(assetId: String) {
        fileService.pauseDownload(fileId: assetId)
    }

    func resumeDownload(assetId: String) {
        fileService.resumeDownload(fileId: assetId)
    }

    func dequeueDownload(assetId: String) {
        fileNamesStorage.deleteFileName(by: assetId)
        fileService.dequeueDownload(fileId: assetId)
    }

    func isDownloaded(assetId: String) -> Bool {
        guard let fileUrl = getAssetUrl(of: assetId) else {
            return false
        }
        return FileManager.default.fileExists(atPath: fileUrl.path)
    }

    func downloadedList() -> [URL] {
        guard let assetsUrl = getAssetsFolderUrl() else {
            return []
        }

        do {
            let files = try FileManager.default.contentsOfDirectory(at: assetsUrl, includingPropertiesForKeys: nil)
            return files
        } catch {
            Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.network)
            return []
        }
    }

    func getLocation(by assetId: String) -> URL? {
        guard isDownloaded(assetId: assetId) else {
            return nil
        }
        return getAssetUrl(of: assetId)
    }

    @discardableResult
    func delete(assetId: String) -> Bool {
        guard isDownloaded(assetId: assetId) else {
            return false
        }
        do {
            guard let fileUrl = getAssetUrl(of: assetId) else {
                return false
            }
            try FileManager.default.removeItem(atPath: fileUrl.path)
            fileNamesStorage.deleteFileName(by: assetId)
            return true
        } catch {
            Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.network)
            return false
        }
    }

    func clear() {
        guard let assetsUrl = getAssetsFolderUrl() else {
            return
        }
        do {
            try FileManager.default.removeItem(atPath: assetsUrl.path)
            fileNamesStorage.fetchFileNames().forEach {
                fileNamesStorage.deleteFileName(by: $0)
            }
        } catch {
            Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.network)
        }
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
        fileService.restore()
    }

}

// MARK: - FileServiceDelegate

extension AssetDownloader: FileServiceDelegate {

    func downloadProgress(fileId: String, progress: Double) {
        Kinescope.shared.logger?.log(message: "Asset \(fileId) download progress: \(progress)", level: KinescopeLoggerLevel.network)
        delegates.forEach {
            $0.assetDownloadProgress(assetId: fileId, progress: progress)
        }
    }

    func downloadError(fileId: String, error: KinescopeDownloadError) {
        Kinescope.shared.logger?.log(message: "Asset \(fileId) download failed with \(error)", level: KinescopeLoggerLevel.network)
        fileNamesStorage.deleteFileName(by: fileId)
        delegates.forEach {
            $0.assetDownloadError(assetId: fileId, error: error)
        }
    }

    func downloadComplete(fileId: String, location: URL) {
        let savedFileUrl: URL?
        let fileUrl = getAssetUrl(of: fileId) ?? .init(fileURLWithPath: "")
        Kinescope.shared.logger?.log(message: "Asset \(fileId) download completed as \(fileUrl)", level: KinescopeLoggerLevel.network)
        do {
            try? FileManager.default.removeItem(at: fileUrl)
            try FileManager.default.copyItem(at: location, to: fileUrl)
            savedFileUrl = fileUrl
        } catch {
            savedFileUrl = nil
            fileNamesStorage.deleteFileName(by: fileId)
            Kinescope.shared.logger?.log(message: "Asset \(fileId) saving failed with \(error)", level: KinescopeLoggerLevel.network)
        }
        delegates.forEach {
            $0.assetDownloadComplete(assetId: fileId, url: savedFileUrl)
        }
    }

}

// MARK: - Private Methods

private extension AssetDownloader {

    func getAssetUrl(of assetId: String) -> URL? {
        guard let name = fileNamesStorage.readFileName(by: assetId) else {
            return nil
        }
        let assetsUrl = getAssetsFolderUrl()
        let destinationUrl = assetsUrl?.appendingPathComponent(assetId + "_" + name)

        return destinationUrl
    }

    func getAssetsFolderUrl() -> URL? {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            Kinescope.shared.logger?.log(error: KinescopeInspectError.denied, level: KinescopeLoggerLevel.network)
            return nil
        }
        let assetsUrl = documentsUrl.appendingPathComponent(Constants.assetsDirectory)

        // Create asset folder if it doesn't exist
        var isDir: ObjCBool = true
        if !FileManager.default.fileExists(atPath: assetsUrl.path, isDirectory: &isDir) {
            do {
                try FileManager.default.createDirectory(at: assetsUrl, withIntermediateDirectories: false, attributes: nil)
            } catch {
                Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.network)
                return nil
            }
        }

        return assetsUrl
    }

}
