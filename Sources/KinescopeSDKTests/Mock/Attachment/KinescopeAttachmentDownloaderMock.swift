//
//  KinescopeAttachmentDownloaderMock.swift
//  KinescopeSDKTests
//
//  Created by Никита Гагаринов on 11.04.2021.
//

import Foundation
@testable import KinescopeSDK

final class KinescopeAttachmentDownloaderMock: KinescopeAttachmentDownloadable {

    func enqueueDownload(attachmentId: String, url: URL) {
    }

    func pauseDownload(attachmentId: String) {
    }

    func resumeDownload(attachmentId: String) {
    }

    func dequeueDownload(attachmentId: String) {
    }

    func isDownloaded(attachmentId: String) -> Bool {
        return true
    }

    func downloadedAttachmentsList() -> [URL] {
        return []
    }

    func delete(attachmentId: String) -> Bool {
        return false
    }

    func clear() {
    }

    func getPath(of attachmentId: String) -> URL? {
        return nil
    }

    func add(delegate: KinescopeAttachmentDownloadableDelegate) {
    }

    func remove(delegate: KinescopeAttachmentDownloadableDelegate) {
    }

    func restore() {
    }

}
