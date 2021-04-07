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
    /// - parameter assetId: Asset id of concrete video quality
    /// - parameter progress: Progress of process
    func kinescopeDownloadProgress(assetId: String, progress: Double)

    /// Notify about error state of downloading task
    ///
    /// - parameter assetId: Asset id of concrete video quality
    /// - parameter error: Reason of failure
    func kinescopeDownloadError(assetId: String, error: KinescopeDownloadError)

    /// Notify about successfully completed downloading task
    ///
    /// - parameter assetId: Asset id of concrete video quality
    func kinescopeDownloadComplete(assetId: String)

}
