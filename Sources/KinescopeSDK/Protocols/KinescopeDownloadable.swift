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
    /// - parameter asset_id: Asset id of concrete video quality
    func isDownloaded(asset_id: String) -> Bool

    /// Request downloadable link for asset and start downloading
    ///
    /// - parameter asset_id: Asset id of concrete video quality
    func enqeueDownload(asset_id: String)

    /// Stop downloading of asset
    ///
    /// - parameter asset_id: Asset id of concrete video quality
    func deqeueDownload(asset_id: String)

    /// Add delegate to notify about download process
    ///
    /// - parameter delegate: Instance of delegate
    func addDelegate(_ delegate: KinescopeDownloadableDelegate)

    /// Remove delegate
    ///
    /// - parameter delegate: Instance of delegate 
    func removeDelegate(_ delegate: KinescopeDownloadableDelegate)

}
