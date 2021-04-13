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

    // MARK: - Initialisation

    init(fileService: FileService,
         assetLinksService: AssetLinksService) {
        self.fileService = fileService
        self.assetLinksService = assetLinksService
        self.fileService.delegate = self
    }

    // MARK: - KinescopeDownloadable

    func enqueueDownload(assetId: String) {
        assetLinksService.getAssetLink(by: assetId) { [weak self] in
            guard let self = self else {
                return
            }
            switch $0 {
            case .success(let link):
                if let url = URL(string: link.link) {
                    self.fileService.enqueueDownload(fileId: self.fileName(for: assetId), url: url)
                }
            case .failure(let error):
                Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.network)
            }
        }
    }

    func pauseDownload(assetId: String) {
        fileService.pauseDownload(fileId: fileName(for: assetId))
    }

    func resumeDownload(assetId: String) {
        fileService.resumeDownload(fileId: fileName(for: assetId))
    }

    func dequeueDownload(assetId: String) {
        fileService.dequeueDownload(fileId: fileName(for: assetId))
    }

    func isDownloaded(assetId: String) -> Bool {
        guard let fileUrl = getAssetUrl(of: fileName(for: assetId)) else {
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
        return getAssetUrl(of: fileName(for: assetId))
    }

    @discardableResult
    func delete(assetId: String) -> Bool {
        guard isDownloaded(assetId: assetId) else {
            return false
        }
        do {
            guard let fileUrl = getAssetUrl(of: fileName(for: assetId)) else {
                return false
            }
            try FileManager.default.removeItem(atPath: fileUrl.path)
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
        delegates.forEach {
            $0.assetDownloadProgress(assetId: fileId, progress: progress)
        }
    }

    func downloadError(fileId: String, error: KinescopeDownloadError) {
        delegates.forEach {
            $0.assetDownloadError(assetId: fileId, error: error)
        }
    }

    func downloadComplete(fileId: String, location: URL) {
        let savedFileUrl: URL?
        do {
            let fileUrl = getAssetUrl(of: fileId) ?? .init(fileURLWithPath: "")
            try FileManager.default.copyItem(at: location, to: fileUrl)
            savedFileUrl = fileUrl
        } catch {
            savedFileUrl = nil
            Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.storage)
        }
        delegates.forEach {
            $0.assetDownloadComplete(assetId: fileId, url: savedFileUrl)
        }
    }

}

// MARK: - Private Methods

private extension AssetDownloader {

    func getAssetUrl(of assetId: String) -> URL? {
        let assetsUrl = getAssetsFolderUrl()
        let destinationUrl = assetsUrl?.appendingPathComponent(assetId)

        return destinationUrl
    }

    func getAssetsFolderUrl() -> URL? {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            Kinescope.shared.logger?.log(error: KinescopeInspectError.denied, level: KinescopeLoggerLevel.storage)
            return nil
        }
        let assetsUrl = documentsUrl.appendingPathComponent(Constants.assetsDirectory)

        // Create asset folder if it doesn't exist
        var isDir : ObjCBool = true
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

    func fileName(for id: String) -> String {
        return id + ".mp4"
    }

}

