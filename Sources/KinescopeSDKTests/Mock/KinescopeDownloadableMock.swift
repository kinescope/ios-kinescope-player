//
//  KinescopeDownloadableMock.swift
//  KinescopeSDKTests
//
//  Created by Artemii Shabanov on 06.04.2021.
//

import Foundation
@testable import KinescopeSDK

final class KinescopeDownloadableMock: KinescopeAssetDownloadable {

    func pauseDownload(assetId: String) {
    }

    func resumeDownload(assetId: String) {
    }

    func restore() {
    }

    func downlaodedAssetsList() -> [String] {
        return []
    }

    func delete(assetId: String) -> Bool {
        return false
    }

    func clear() {
    }

    func getPath(by assetId: String) -> URL? {
        return nil
    }

    func isDownloaded(assetId: String) -> Bool {
        return true
    }

    func enqueueDownload(assetId: String) {
    }

    func dequeueDownload(assetId: String) {
    }

    func add(delegate: KinescopeAssetDownloadableDelegate) {
    }

    func remove(delegate: KinescopeAssetDownloadableDelegate) {
    }

    // TODO: add logic

}
