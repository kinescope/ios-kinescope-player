//
//  KinescopeDownloadable.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//

import Foundation

/// Control protocol managing downloading of assets(concrete quality)
public protocol KinescopeAssetDownloadable: class {

    /// Request downloadable link for asset and start downloading
    ///
    /// - parameter assetId: Asset id of concrete video quality
    func enqueueDownload(assetId: String)

    /// Pause downloading of asset
    ///
    /// - parameter assetId: Asset id of concrete video quality
    func pauseDownload(assetId: String)

    /// Resume downloading of asset
    ///
    /// - parameter assetId: Asset id of concrete video quality
    func resumeDownload(assetId: String)

    /// Stop downloading of asset
    ///
    /// - parameter assetId: Asset id of concrete video quality
    func dequeueDownload(assetId: String)

    /// Checks that asset of concrete quality was downloaded
    ///
    /// - parameter assetId: Asset id of concrete video quality
    func isDownloaded(assetId: String) -> Bool

    /// Returns list of downloaded assets Id's
    func downloadedList() -> [URL]

    /// Returns downloaded asset path from disk
    ///
    /// - parameter assetId: Asset id of concrete video quality
    func getLocation(by assetId: String) -> URL?

    /// Deletes downloaded asset from disk
    ///
    /// - parameter assetId: Asset id of concrete video quality
    @discardableResult
    func delete(assetId: String) -> Bool

    /// Deletes all downloaded assets from disk
    func clear()

    /// Add delegate to notify about download process
    ///
    /// - parameter delegate: Instance of delegate
    func add(delegate: KinescopeAssetDownloadableDelegate)

    /// Remove delegate
    ///
    /// - parameter delegate: Instance of delegate 
    func remove(delegate: KinescopeAssetDownloadableDelegate)

    /// Restore downloads which were interrupted by app close
    func restore()

}
