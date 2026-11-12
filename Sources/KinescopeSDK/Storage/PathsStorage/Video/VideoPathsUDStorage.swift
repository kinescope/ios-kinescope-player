//
//  AssetPathsUDStorage.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 06.04.2021.
//

import Foundation

final class VideoPathsUDStorage: KinescopeVideoPathsStorage {

    // MARK: - Properties

    private let udStroage = PathsUDStorage(suffix: "videos")

    // MARK: - KinescopeAssetPathsStorage

    func saveVideo(relativeUrl: String, id videoId: String) {
        udStroage.save(relativeUrl: relativeUrl, id: videoId)
    }

    func saveBookmark(for url: URL, id videoId: String) throws {
        let data = try url.bookmarkData(options: [],
                                        includingResourceValuesForKeys: nil,
                                        relativeTo: nil)
        let stored = Self.bookmarkPrefix + data.base64EncodedString()
        udStroage.save(relativeUrl: stored, id: videoId)
    }

    func readVideoUrl(by videoId: String) -> URL? {
        guard let stored = udStroage.readUrl(by: videoId) else {
            return nil
        }
        if stored.hasPrefix(Self.bookmarkPrefix) {
            return resolveBookmark(stored, videoId: videoId)
        }
        return constructUrl(relativeUrl: stored)
    }

    func fetchVideoIds() -> [String] {
        return udStroage.fetchIds()
    }

    @discardableResult
    func deleteVideoUrl(by videoId: String) -> URL? {
        return constructUrl(relativeUrl: udStroage.deleteUrl(by: videoId))
    }

    // MARK: - Private

    private static let bookmarkPrefix = "bookmark:"

    private func resolveBookmark(_ stored: String, videoId: String) -> URL? {
        let encoded = String(stored.dropFirst(Self.bookmarkPrefix.count))
        guard let data = Data(base64Encoded: encoded) else {
            return nil
        }
        var isStale = false
        guard let url = try? URL(resolvingBookmarkData: data,
                                 options: [],
                                 relativeTo: nil,
                                 bookmarkDataIsStale: &isStale) else {
            return nil
        }
        if isStale {
            try? saveBookmark(for: url, id: videoId)
        }
        return url
    }

    private func constructUrl(relativeUrl: String?) -> URL? {
        guard let relativeUrl = relativeUrl else {
            return nil
        }
        if relativeUrl.hasPrefix("/") {
            return URL(fileURLWithPath: relativeUrl)
        }
        let baseURL = URL(fileURLWithPath: NSHomeDirectory())
        return baseURL.appendingPathComponent(relativeUrl)
    }

}
