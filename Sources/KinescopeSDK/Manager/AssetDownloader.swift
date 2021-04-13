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
        static let assetsDirectory = "KinescopeAttachments"
    }

    // MARK: - Properties

    private var delegates: [KinescopeAssetDownloadableDelegate] = []
    private var fileService: FileService

    // MARK: - Initialisation

    init(fileService: FileService) {
        self.fileService = fileService
        self.fileService.delegate = self
    }

    // MARK: - KinescopeDownloadable

    func downlaodedList() -> [URL] {
        let assetsUrl = getAssetFolderUrl()
        let files = try? FileManager.default.contentsOfDirectory(at: assetsUrl, includingPropertiesForKeys: nil)
        return files ?? []
    }

    @discardableResult
    func delete(assetId: String) -> Bool {
        guard isDownloaded(assetId: assetId) else {
            return false
        }
        do {
            let fileUrl = getAssetUrl(of: assetId)
            try FileManager.default.removeItem(atPath: fileUrl.path)
            return true
        } catch {
            Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.storage)
            return false
        }
    }

    func clear() {
        let assetsUrl = getAssetFolderUrl()
        try? FileManager.default.removeItem(atPath: assetsUrl.path)
    }

    func getPath(by assetId: String) -> URL? {
        guard isDownloaded(assetId: assetId) else {
            return nil
        }
        return getAssetUrl(of: assetId)
    }

    func enqueueDownload(assetId: String) {
        fileService.enqueueDownload(fileId: assetId, url: <#T##URL#>)
    }

    func pauseDownload(assetId: String) {
        fileService.pauseDownload(fileId: assetId)
    }

    func resumeDownload(assetId: String) {
        fileService.resumeDownload(fileId: assetId)
    }

    func dequeueDownload(assetId: String) {
        fileService.dequeueDownload(fileId: assetId)
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

    func isDownloaded(assetId: String) -> Bool {
        let fileUrl = getAssetUrl(of: assetId)
        return FileManager.default.fileExists(atPath: fileUrl.path)
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

    func downloadComplete(fileId: String, path: URL) {
        let savedFileUrl: URL?
        do {
            let fileUrl = getAssetUrl(of: fileId)
            try FileManager.default.copyItem(at: path, to: fileUrl)
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

    func getAssetUrl(of assetId: String) -> URL {
        let assetsUrl = getAssetFolderUrl()
        let destinationUrl = assetsUrl.appendingPathComponent(assetId)

        return destinationUrl
    }

    func getAssetFolderUrl() -> URL {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            Kinescope.shared.logger?.log(error: KinescopeInspectError.denied, level: KinescopeLoggerLevel.storage)
            return URL(fileURLWithPath: "")
        }
        let assetsUrl = documentsUrl.appendingPathComponent(Constants.assetsDirectory)

        // Create asset folder if it doesn't exist
        var isDir : ObjCBool = true
        if !FileManager.default.fileExists(atPath: assetsUrl.path, isDirectory: &isDir) {
            try? FileManager.default.createDirectory(at: assetsUrl, withIntermediateDirectories: false, attributes: nil)
        }

        return assetsUrl
    }

}

