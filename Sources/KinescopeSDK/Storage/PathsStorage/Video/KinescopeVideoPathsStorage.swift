//
//  UserDefaults+video.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 06.04.2021.
//

import Foundation

/// It should provide consistency of saved and read urls
protocol KinescopeVideoPathsStorage {
    func saveVideo(relativeUrl: String, id videoId: String)
    /// Returns full url
    func readVideoUrl(by videoId: String) -> URL?
    func fetchVideoIds() -> [String]
    /// Returns full url
    @discardableResult
    func deleteVideoUrl(by videoId: String) -> URL?
}
