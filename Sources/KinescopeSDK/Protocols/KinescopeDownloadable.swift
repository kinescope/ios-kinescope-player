//
//  KinescopeDownloadable.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//

/// Control protocol managing downloading of assets
public protocol KinescopeDownloadable: class {

    /// Checks that asset were downloaded
    ///
    /// - parameter assetId: Asset id of concrete video quality
    func isDownloaded(assetId: String) -> Bool

    /// Returns list of downloaded assets Id's
    func downlaodedAssetsList() -> [String]

    /// Deletes downloaded asset from disk
    ///
    /// - parameter assetId: Asset id of concrete video quality
    @discardableResult
    func delete(assetId: String) -> Bool

    /// Request downloadable link for asset and start downloading
    ///
    /// - parameter assetId: Asset id of concrete video quality
    func enqeueDownload(assetId: String)

    /// Stop downloading of asset
    ///
    /// - parameter assetId: Asset id of concrete video quality
    func deqeueDownload(assetId: String)

    /// Add delegate to notify about download process
    ///
    /// - parameter delegate: Instance of delegate
    func add(delegate: KinescopeDownloadableDelegate)

    /// Remove delegate
    ///
    /// - parameter delegate: Instance of delegate 
    func remove(delegate: KinescopeDownloadableDelegate)

}

public extension KinescopeDownloadable {

    func isDownloaded(assetId: String) -> Bool {
        return downlaodedAssetsList().contains(assetId)
    }

}
