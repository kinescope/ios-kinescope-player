//
//  AssetPathsUDStorage.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 06.04.2021.
//

import Foundation

/// KinescopeVideoPathsStorage implementation based on PathsUDStorage
final class VideoPathsUDStorage: KinescopeVideoPathsStorage {

    // MARK: - Properties

    private let udStroage = PathsUDStorage(suffix: "videos")

    // MARK: - KinescopeAssetPathsStorage

    func saveVideo(relativeUrl: String, id videoId: String) {
        udStroage.save(relativeUrl: relativeUrl, id: videoId)
    }

    func readVideoUrl(by videoId: String) -> URL? {
        return constructUrl(relativeUrl: udStroage.readUrl(by: videoId))
    }

    func fetchVideoIds() -> [String] {
        return udStroage.fetchIds()
    }

    @discardableResult
    func deleteVideoUrl(by videoId: String) -> URL? {
        return constructUrl(relativeUrl: udStroage.deleteUrl(by: videoId))
    }

    // MARK: - Private

    private func constructUrl(relativeUrl: String?) -> URL? {
        guard let relativeUrl = relativeUrl else {
            return nil
        }
        let baseURL = URL(fileURLWithPath: NSHomeDirectory())
        let assetURL = baseURL.appendingPathComponent(relativeUrl)
        return assetURL
    }

}
