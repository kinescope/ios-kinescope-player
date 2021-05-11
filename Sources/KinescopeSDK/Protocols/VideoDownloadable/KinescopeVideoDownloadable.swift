//
//  KinescopeVideoDownloadable.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 13.04.2021.
//

import Foundation

/// Control protocol managing downloading of assets and videos
public protocol KinescopeVideoDownloadable: AnyObject {

    /// Request downloadable link for video and start downloading
    ///
    /// - parameter videoId: Video id
    /// - parameter url: web URL of video
    func enqueueDownload(videoId: String, url: URL)

    /// Pause downloading of asset
    ///
    /// - parameter videoId: Video id
    func pauseDownload(videoId: String)

    /// Resume downloading of asset
    ///
    /// - parameter videoId: Video id
    func resumeDownload(videoId: String)

    /// Stop downloading of asset
    ///
    /// - parameter videoId: Video id
    func dequeueDownload(videoId: String)

    /// Checks that video was downloaded
    ///
    /// - parameter videoId: Video id
    func isDownloaded(videoId: String) -> Bool

    /// Returns list of downloaded video Id's
    func downloadedList() -> [String]

    /// Returns downloaded video path from disk
    ///
    /// - parameter videoId: Video id
    func getLocation(by videoId: String) -> URL?

    /// Deletes downloaded asset from disk
    ///
    /// - parameter videoId: Video id
    @discardableResult
    func delete(videoId: String) -> Bool

    /// Deletes all downloaded videos from disk
    func clear()

    /// Add delegate to notify about download process
    ///
    /// - parameter delegate: Instance of delegate
    func add(delegate: KinescopeVideoDownloadableDelegate)

    /// Remove delegate
    ///
    /// - parameter delegate: Instance of delegate
    func remove(delegate: KinescopeVideoDownloadableDelegate)

    /// Restore downloads which were interrupted by app close
    func restore()

}

public extension KinescopeVideoDownloadable {

    func isDownloaded(videoId: String) -> Bool {
        return downloadedList().contains(videoId)
    }

}
