//
//  UserDefaults+video.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 06.04.2021.
//

import Foundation

/// It should provide consistency of saved and read urls
protocol KinescopeAssetPathsStorage {
    func saveAsset(relativeUrl: String, id assetId: String)
    /// Returns full url
    func readVideoUrl(by assetId: String) -> URL?
    func fetchAssetIds() -> [String]
    /// Returns full url
    @discardableResult
    func deleteVideoUrl(by assetId: String) -> URL?
}
