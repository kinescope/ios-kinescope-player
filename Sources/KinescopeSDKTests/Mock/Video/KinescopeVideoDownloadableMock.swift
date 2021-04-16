//
//  KinescopeVideoDownloadableMock.swift
//  KinescopeSDKTests
//
//  Created by Artemii Shabanov on 13.04.2021.
//

import Foundation
@testable import KinescopeSDK

final class KinescopeVideoDownloadableMock: KinescopeVideoDownloadable {

    func enqueueDownload(videoId: String, url: URL) {
    }

    func dequeueDownload(videoId: String) {
    }

    func pauseDownload(videoId: String) {
    }

    func resumeDownload(videoId: String) {
    }

    func downloadedList() -> [String] {
        return []
    }

    func getLocation(by videoId: String) -> URL? {
        return nil
    }

    func delete(videoId: String) -> Bool {
        return false
    }

    func clear() {
    }

    func isDownloaded(videoId: String) -> Bool {
        return true
    }

    func add(delegate: KinescopeVideoDownloadableDelegate) {
    }

    func remove(delegate: KinescopeVideoDownloadableDelegate) {
    }

    func restore() {
    }

}
