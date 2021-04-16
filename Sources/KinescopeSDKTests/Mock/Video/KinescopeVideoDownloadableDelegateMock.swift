//
//  KinescopeVideoDownloadableDelegateMock.swift
//  KinescopeSDKTests
//
//  Created by Artemii Shabanov on 08.04.2021.
//
// swiftlint:disable large_tuple

@testable import KinescopeSDK

final class KinescopeVideoDownloadableDelegateMock: KinescopeVideoDownloadableDelegate {

    var videos: [String: (progress: Double, completed: Bool, error: KinescopeDownloadError?)] = [:]

    func videoDownloadProgress(videoId: String, progress: Double) {
        videos[videoId]?.progress = progress
    }

    func videoDownloadError(videoId: String, error: KinescopeDownloadError) {
        videos[videoId]?.error = error
    }

    func videoDownloadComplete(videoId: String) {
        videos[videoId]?.completed = true
    }
}
