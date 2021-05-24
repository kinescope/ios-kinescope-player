//
//  UserDefaults+video.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 06.04.2021.
//

import Foundation

/// Manages videos urls to its ids pairs staring
/// It should provide consistency of saved and read urls
protocol KinescopeVideoPathsStorage {
    /// Saves video url by its id
    /// - Parameters:
    ///   - relativeUrl: relative url to video on device disk
    ///   - videoId: video id
    func saveVideo(relativeUrl: String, id videoId: String)
    /// Returns full url to video file
    /// - Parameter videoId: video id
    func readVideoUrl(by videoId: String) -> URL?
    /// Returns list of saved videos
    func fetchVideoIds() -> [String]
    /// Deletes url - id pair
    /// Returns full url
    @discardableResult
    func deleteVideoUrl(by videoId: String) -> URL?
}
