//
//  KinescopeDownloadableMock.swift
//  KinescopeSDKTests
//
//  Created by Artemii Shabanov on 06.04.2021.
//

@testable import KinescopeSDK

final class KinescopeDownloadableMock: KinescopeDownloadable {
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
