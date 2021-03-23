//
//  VideoDownloader.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//

// MARK: - KinescopeDownloadable

class VideoDownloader: KinescopeDownloadable {

    // MARK: - Properties

    private var delegates: [KinescopeDownloadableDelegate] = []

    private let apiKey: String

    // MARK: - Initialisation

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    // MARK: - Methods

    func isDownloaded(assetId: String) -> Bool {
        preconditionFailure("Implement")
    }

    func enqeueDownload(assetId: String) {
        preconditionFailure("Implement")
    }

    func deqeueDownload(assetId: String) {
        preconditionFailure("Implement")
    }

    func add(delegate: KinescopeDownloadableDelegate) {
        delegates.append(delegate)
    }

    func remove(delegate: KinescopeDownloadableDelegate) {
        if let index = delegates.firstIndex(where: { delegate === $0 }) {
            delegates.remove(at: index)
        }
    }

}
