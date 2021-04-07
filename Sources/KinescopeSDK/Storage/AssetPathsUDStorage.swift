//
//  AssetPathsUDStorage.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 06.04.2021.
//

import Foundation

final class AssetPathsUDStorage: KinescopeAssetPathsStorage {

    // MARK: - Properties

    private let udStroage = PathsUDStorage(suffix: "videos")

    // MARK: - KinescopeAssetPathsStorage

    func saveAsset(relativeUrl: String, id assetId: String) {
        udStroage.save(relativeUrl: relativeUrl, id: assetId)
    }

    func readVideoUrl(by assetId: String) -> URL? {
        return constructUrl(relativeUrl: udStroage.readUrl(by: assetId))
    }

    func fetchAssetIds() -> [String] {
        return udStroage.fetchIds()
    }
    
    @discardableResult
    func deleteVideoUrl(by assetId: String) -> URL? {
        return constructUrl(relativeUrl: udStroage.deleteUrl(by: assetId))
    }

    // MARK: - Private

    private func constructUrl(relativeUrl: String?) -> URL? {
        guard let relativeUrl = relativeUrl else { return nil}
        let baseURL = URL(fileURLWithPath: NSHomeDirectory())
        let assetURL = baseURL.appendingPathComponent(relativeUrl)
        return assetURL
    }

}
