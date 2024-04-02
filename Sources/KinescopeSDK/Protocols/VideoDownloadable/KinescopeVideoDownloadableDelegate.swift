//
//  KinescopeVideoDownloadableDelegate.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 13.04.2021.
//

import Foundation

/// Delegate protocol to listen videos download process events
public protocol KinescopeVideoDownloadableDelegate: AnyObject {

    /// Notify about progress state of downloading task
    ///
    /// - parameter videoId: Video id
    /// - parameter progress: Progress of process
    func videoDownloadProgress(videoId: String, progress: Double)

    /// Notify about error state of downloading task
    ///
    /// - parameter videoId: Video id
    /// - parameter error: Reason of failure
    func videoDownloadError(videoId: String, error: KinescopeDownloadError)

    /// Notify about successfully completed downloading task
    ///
    /// - parameter videoId: Video id
    func videoDownloadComplete(videoId: String)

}
