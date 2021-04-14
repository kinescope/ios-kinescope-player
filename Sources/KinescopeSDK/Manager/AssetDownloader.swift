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

    private var delegates: [KinescopeAssetDownloadableDelegate] = []
    private var fileService: FileService
    private let assetLinksService: AssetLinksService
    private var fileNamesStorage: KinescopeFileNamesStorage

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

    func enqueueDownload(asset: KinescopeVideoAsset) {
        assetLinksService.getAssetLink(by: asset.id) { [weak self] in
            guard let self = self else {
                return
            }
            switch $0 {
            case .success(let link):
                if let url = URL(string: link.link) {
                    self.fileService.enqueueDownload(fileId: asset.id, url: url)
                    self.fileNamesStorage.saveFile(name: asset.originalName, id: asset.id)
                }
            case .failure(let error):
                Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.network)
            }
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
            Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.storage)
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
            Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.storage)
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
            Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.storage)
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
        Kinescope.shared.logger?.log(message: "Asset \(fileId) download progress: \(progress)", level: KinescopeLoggerLevel.storage)
        delegates.forEach {
            $0.assetDownloadProgress(assetId: fileId, progress: progress)
        }
    }

    func downloadError(fileId: String, error: KinescopeDownloadError) {
        Kinescope.shared.logger?.log(message: "Asset \(fileId) download failed with \(error)", level: KinescopeLoggerLevel.storage)
        fileNamesStorage.deleteFileName(by: fileId)
        delegates.forEach {
            $0.assetDownloadError(assetId: fileId, error: error)
        }
    }

    func downloadComplete(fileId: String, location: URL) {
        let savedFileUrl: URL?
        let fileUrl = getAssetUrl(of: fileId) ?? .init(fileURLWithPath: "")
        Kinescope.shared.logger?.log(message: "Asset \(fileId) download completed as \(fileUrl)", level: KinescopeLoggerLevel.storage)
        do {
            try FileManager.default.copyItem(at: location, to: fileUrl)
            savedFileUrl = fileUrl
        } catch {
            savedFileUrl = nil
            Kinescope.shared.logger?.log(message: "Asset \(fileId) saving failed with \(error)", level: KinescopeLoggerLevel.storage)
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
            Kinescope.shared.logger?.log(error: KinescopeInspectError.denied, level: KinescopeLoggerLevel.storage)
            return nil
        }
        let assetsUrl = documentsUrl.appendingPathComponent(Constants.assetsDirectory)

        // Create asset folder if it doesn't exist
        var isDir: ObjCBool = true
        if !FileManager.default.fileExists(atPath: assetsUrl.path, isDirectory: &isDir) {
            do {
                try FileManager.default.createDirectory(at: assetsUrl, withIntermediateDirectories: false, attributes: nil)
            } catch {
                Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.storage)
                return nil
            }
        }

        return assetsUrl
    }

}
