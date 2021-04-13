//
//  FileDownloader.swift
//  KinescopeSDK
//
//  Created by Никита Гагаринов on 08.04.2021.
//

import Foundation

class AttachmentDownloader: KinescopeAttachmentDownloadable {

    // MARK: - Constants

    private enum Constants {
        static let attachmentsDirectory = "KinescopeAttachments"
    }

    // MARK: - Properties

    private var fileService: FileService
    private var delegates: [KinescopeAttachmentDownloadableDelegate] = []

    // MARK: - Initialisation

    init(fileService: FileService) {
        self.fileService = fileService
        self.fileService.delegate = self
    }

    // MARK: - KinescopeAttachmentDownloadable

    func downloadedAttachmentsList() -> [URL] {
        let attachmentsUrl = getAttachmentsFolderUrl()
        let files = try? FileManager.default.contentsOfDirectory(at: attachmentsUrl, includingPropertiesForKeys: nil)
        return files ?? []
    }

    func enqueueDownload(attachmentId: String, url: URL) {
        guard !isDownloaded(attachmentId: attachmentId) else {
            return
        }
        fileService.enqueueDownload(fileId: attachmentId, url: url)
    }

    func dequeueDownload(attachmentId: String) {
        fileService.dequeueDownload(fileId: attachmentId)
    }

    func pauseDownload(attachmentId: String) {
        fileService.pauseDownload(fileId: attachmentId)
    }

    func resumeDownload(attachmentId: String) {
        fileService.resumeDownload(fileId: attachmentId)
    }

    @discardableResult
    func delete(attachmentId: String) -> Bool {
        guard isDownloaded(attachmentId: attachmentId) else {
            return false
        }
        do {
            let fileUrl = getAttachmentUrl(of: attachmentId)
            try FileManager.default.removeItem(atPath: fileUrl.path)
            return true
        } catch {
            Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.storage)
            return false
        }
    }

    func getPath(of attachmentId: String) -> URL? {
        guard isDownloaded(attachmentId: attachmentId) else {
            return nil
        }
        return getAttachmentUrl(of: attachmentId)
    }

    func isDownloaded(attachmentId: String) -> Bool {
        let fileUrl = getAttachmentUrl(of: attachmentId)
        return FileManager.default.fileExists(atPath: fileUrl.path)
    }

    func add(delegate: KinescopeAttachmentDownloadableDelegate) {
        delegates.append(delegate)
    }

    func remove(delegate: KinescopeAttachmentDownloadableDelegate) {
        if let index = delegates.firstIndex(where: { delegate === $0 }) {
            delegates.remove(at: index)
        }
    }

    func restore() {
        fileService.restore()
    }

    func clear() {
        let attachmentsUrl = getAttachmentsFolderUrl()
        try? FileManager.default.removeItem(atPath: attachmentsUrl.path)
    }

}

// MARK: - FileServiceDelegate

extension AttachmentDownloader: FileServiceDelegate {

    func downloadProgress(fileId: String, progress: Double) {
        delegates.forEach {
            $0.attachmentDownloadProgress(attachmentId: fileId, progress: progress)
        }
    }

    func downloadError(fileId: String, error: KinescopeDownloadError) {
        delegates.forEach {
            $0.attachmentDownloadError(attachmentId: fileId, error: error)
        }
    }

    func downloadComplete(fileId: String, path: URL) {
        let savedFileUrl: URL?
        do {
            let fileUrl = getAttachmentUrl(of: fileId)
            try FileManager.default.copyItem(at: path, to: fileUrl)
            savedFileUrl = fileUrl
        } catch {
            savedFileUrl = nil
            Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.storage)
        }
        delegates.forEach {
            $0.attachmentDownloadComplete(attachmentId: fileId, url: savedFileUrl)
        }
    }

}

// MARK: - Private Methods

private extension AttachmentDownloader {

    func getAttachmentUrl(of attachmentId: String) -> URL {
        let attachmentsUrl = getAttachmentsFolderUrl()
        let destinationUrl = attachmentsUrl.appendingPathComponent(attachmentId)

        return destinationUrl
    }

    func getAttachmentsFolderUrl() -> URL {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            Kinescope.shared.logger?.log(error: KinescopeInspectError.denied, level: KinescopeLoggerLevel.storage)
            return URL(fileURLWithPath: "")
        }
        let attachmentsUrl = documentsUrl.appendingPathComponent(Constants.attachmentsDirectory)

        // Create attachment folder if it doesn't exist
        var isDir : ObjCBool = true
        if !FileManager.default.fileExists(atPath: attachmentsUrl.path, isDirectory: &isDir) {
            try? FileManager.default.createDirectory(at: attachmentsUrl, withIntermediateDirectories: false, attributes: nil)
        }
        
        return attachmentsUrl
    }

}
