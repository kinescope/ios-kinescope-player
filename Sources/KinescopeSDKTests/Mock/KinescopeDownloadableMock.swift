//
//  KinescopeDownloadableMock.swift
//  KinescopeSDKTests
//
//  Created by Artemii Shabanov on 06.04.2021.
//

import Foundation
@testable import KinescopeSDK

final class KinescopeDownloadableMock: KinescopeDownloadable {

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

    func enqeueDownload(assetId: String) {
    }

    func deqeueDownload(assetId: String) {
    }

    func add(delegate: KinescopeDownloadableDelegate) {
    }

    func remove(delegate: KinescopeDownloadableDelegate) {
    }

    // TODO: add logic

}
