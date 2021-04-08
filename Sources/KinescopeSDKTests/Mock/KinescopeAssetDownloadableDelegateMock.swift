//
//  KinescopeAssetDownloadableDelegateMock.swift
//  KinescopeSDKTests
//
//  Created by Artemii Shabanov on 08.04.2021.
//
// swiftlint:disable large_tuple

@testable import KinescopeSDK

final class KinescopeAssetDownloadableDelegateMock: KinescopeAssetDownloadableDelegate {
    var assets: [String: (progress: Double, completed: Bool, error: KinescopeDownloadError?)] = [:]

    func kinescopeDownloadProgress(assetId: String, progress: Double) {
        assets[assetId]?.progress = progress
    }

    func kinescopeDownloadError(assetId: String, error: KinescopeDownloadError) {
        assets[assetId]?.error = error
    }

    func kinescopeDownloadComplete(assetId: String) {
        assets[assetId]?.completed = true
    }
}
