//
//  FileDownloader.swift
//  KinescopeSDK
//
//  Created by Никита Гагаринов on 08.04.2021.
//

import Foundation

/// Base KinescopeAttachmentDownloadable implementation
class AttachmentDownloader: KinescopeAttachmentDownloadable {

    // MARK: - Constants

    private enum Constants {
        static let attachmentsDirectory = "KinescopeAttachments"
    }

    // MARK: - Properties

    private var fileService: FileService
    private var delegates: [KinescopeAttachmentDownloadableDelegate] = []
    private var fileNamesStorage: KinescopeFileNamesStorage

    // MARK: - Initialisation

    init(fileService: FileService, fileNamesStorage: KinescopeFileNamesStorage = FileNamesUDStorage(suffix: "attachmentNames")) {
        self.fileService = fileService
        self.fileNamesStorage = fileNamesStorage
        self.fileService.delegate = self
    }

    // MARK: - KinescopeAttachmentDownloadable

    func enqueueDownload(attachment: KinescopeVideoAdditionalMaterial) {
        guard
            let url = URL(string: attachment.url),
            !isDownloaded(attachmentId: attachment.id)
        else {
            return
        }
        fileNamesStorage.saveFile(name: attachment.filename, id: attachment.id)
        fileService.enqueueDownload(fileId: attachment.id, url: url)
    }

    func dequeueDownload(attachmentId: String) {
        fileNamesStorage.deleteFileName(by: attachmentId)
        fileService.dequeueDownload(fileId: attachmentId)
    }

    func pauseDownload(attachmentId: String) {
        fileService.pauseDownload(fileId: attachmentId)
    }

    func resumeDownload(attachmentId: String) {
        fileService.resumeDownload(fileId: attachmentId)
    }

    func isDownloaded(attachmentId: String) -> Bool {
        guard let fileUrl = getAttachmentUrl(of: attachmentId) else {
            return false
        }
        return FileManager.default.fileExists(atPath: fileUrl.path)
    }

    func downloadedList() -> [URL] {
        guard let attachmentsUrl = getAttachmentsFolderUrl() else {
            return []
        }

        do {
            let files = try FileManager.default.contentsOfDirectory(at: attachmentsUrl, includingPropertiesForKeys: nil)
            return files
        } catch {
            Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.network)
            return []
        }
    }

    func getLocation(of attachmentId: String) -> URL? {
        guard isDownloaded(attachmentId: attachmentId) else {
            return nil
        }
        return getAttachmentUrl(of: attachmentId)
    }

    @discardableResult
    func delete(attachmentId: String) -> Bool {
        guard isDownloaded(attachmentId: attachmentId) else {
            return false
        }
        do {
            guard let fileUrl = getAttachmentUrl(of: attachmentId) else {
                return false
            }
            try FileManager.default.removeItem(atPath: fileUrl.path)
            fileNamesStorage.deleteFileName(by: attachmentId)
            return true
        } catch {
            Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.network)
            return false
        }
    }

    func clear() {
        guard let attachmentsUrl = getAttachmentsFolderUrl() else {
            return
        }
        do {
            try FileManager.default.removeItem(atPath: attachmentsUrl.path)
            fileNamesStorage.fetchFileNames().forEach {
                fileNamesStorage.deleteFileName(by: $0)
            }
        } catch {
            Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.network)
        }
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

}

// MARK: - FileServiceDelegate

extension AttachmentDownloader: FileServiceDelegate {

    func downloadProgress(fileId: String, progress: Double) {
        Kinescope.shared.logger?.log(message: "Attachment \(fileId) download progress: \(progress)", level: KinescopeLoggerLevel.network)
        delegates.forEach {
            $0.attachmentDownloadProgress(attachmentId: fileId, progress: progress)
        }
    }

    func downloadError(fileId: String, error: KinescopeDownloadError) {
        Kinescope.shared.logger?.log(message: "Attachment \(fileId) download failed with \(error)", level: KinescopeLoggerLevel.network)
        fileNamesStorage.deleteFileName(by: fileId)
        delegates.forEach {
            $0.attachmentDownloadError(attachmentId: fileId, error: error)
        }
    }

    func downloadComplete(fileId: String, location: URL) {
        let savedFileUrl: URL?
        let fileUrl = getAttachmentUrl(of: fileId) ?? .init(fileURLWithPath: "")
        Kinescope.shared.logger?.log(message: "Attachment \(fileId) download completed as \(fileUrl)", level: KinescopeLoggerLevel.network)
        do {
            try FileManager.default.copyItem(at: location, to: fileUrl)
            savedFileUrl = fileUrl
        } catch {
            savedFileUrl = nil
            fileNamesStorage.deleteFileName(by: fileId)
            Kinescope.shared.logger?.log(message: "Attachment \(fileId) saving failed with \(error)", level: KinescopeLoggerLevel.network)
        }
        delegates.forEach {
            $0.attachmentDownloadComplete(attachmentId: fileId, url: savedFileUrl)
        }
    }

}

// MARK: - Private Methods

private extension AttachmentDownloader {

    func getAttachmentUrl(of attachmentId: String) -> URL? {
        guard let name = fileNamesStorage.readFileName(by: attachmentId) else {
            return nil
        }
        let attachmentsUrl = getAttachmentsFolderUrl()
        let destinationUrl = attachmentsUrl?.appendingPathComponent(attachmentId + "_" + name)

        return destinationUrl
    }

    func getAttachmentsFolderUrl() -> URL? {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            Kinescope.shared.logger?.log(error: KinescopeInspectError.denied, level: KinescopeLoggerLevel.network)
            return nil
        }
        let attachmentsUrl = documentsUrl.appendingPathComponent(Constants.attachmentsDirectory)

        // Create attachment folder if it doesn't exist
        var isDir: ObjCBool = true
        if !FileManager.default.fileExists(atPath: attachmentsUrl.path, isDirectory: &isDir) {
            do {
                try FileManager.default.createDirectory(at: attachmentsUrl, withIntermediateDirectories: false, attributes: nil)
            } catch {
                Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.network)
                return nil
            }
        }

        return attachmentsUrl
    }

}
