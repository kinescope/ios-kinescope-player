//
//  KinescopeDownloadableDelegate.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//

import Foundation

/// Delegate protocol to listen download process events
public protocol KinescopeDownloadableDelegate: class {

    /// Notify about progress state of downloading task
    ///
    /// - parameter asset_id: Asset id of concrete video quality
    /// - parameter progress: Progress of process
    func kinescopeDownloadProgress(asset_id: String, progress: Progress)

    /// Notify about error state of downloading task
    ///
    /// - parameter asset_id: Asset id of concrete video quality
    /// - parameter error: Reason of failure
    func kinescopeDownloadError(asset_id: String, error: KinescopeDownloadError)

    /// Notify about successfully completed downloading task
    ///
    /// - parameter asset_id: Asset id of concrete video quality
    func kinescopeDownloadComplete(asset_id: String)

}
