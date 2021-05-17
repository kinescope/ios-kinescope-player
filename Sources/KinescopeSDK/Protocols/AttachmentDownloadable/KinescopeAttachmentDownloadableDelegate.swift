//
//  KinescopeFileDownloadableDelegate.swift
//  KinescopeSDK
//
//  Created by Никита Гагаринов on 09.04.2021.
//

import Foundation

/// Delegate protocol to listen attachments download file process events
public protocol KinescopeAttachmentDownloadableDelegate: AnyObject {

    /// Notify about progress state of downloading task
    ///
    /// - parameter attachmentId: Id of downloading attachment
    /// - parameter progress: Progress of process
    func attachmentDownloadProgress(attachmentId: String, progress: Double)

    /// Notify about error state of downloading task
    ///
    /// - parameter attachmentId: Id of downloading attachment
    /// - parameter error: Reason of failure
    func attachmentDownloadError(attachmentId: String, error: KinescopeDownloadError)

    /// Notify about successfully completed downloading task
    ///
    /// - parameter attachmentId: Id of downloading attachment
    /// - parameter url: URL path to cache of saved attachment file, nil if attachment didn't saved
    func attachmentDownloadComplete(attachmentId: String, url: URL?)

}
