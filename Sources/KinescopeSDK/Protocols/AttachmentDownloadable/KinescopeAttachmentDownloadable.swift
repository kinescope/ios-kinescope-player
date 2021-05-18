//
//  KinescopeFileDownloadable.swift
//  KinescopeSDK
//
//  Created by Никита Гагаринов on 09.04.2021.
//

import Foundation

/// Control protocol managing downloading of attachments
public protocol KinescopeAttachmentDownloadable: AnyObject {

    /// Start downloading attachment
    /// Downloading won't start if the attachment already stored on disk
    ///
    /// - parameter attachment: Attachment's model
    func enqueueDownload(attachment: KinescopeVideoAdditionalMaterial)

    /// Pause downloading of attachment
    ///
    /// - parameter attachmentId: id of attachment's file
    func pauseDownload(attachmentId: String)

    /// Resume downloading of attachment
    ///
    /// - parameter attachmentId: id of attachment's file
    func resumeDownload(attachmentId: String)

    /// Stop downloading of attachment
    ///
    /// - parameter attachmentId: id of attachment's file
    func dequeueDownload(attachmentId: String)

    /// Checks that attachment was downloaded
    ///
    /// - parameter attachmentId: id of attachment's file
    func isDownloaded(attachmentId: String) -> Bool

    /// Returns list of downloaded attachments url's that stored on disk
    func downloadedList() -> [URL]

    /// Returns location of downloaded attachment in cache if the file exist, returns nil otherwise
    ///
    /// - parameter attachmentId: id of attachment's file
    func getLocation(of attachmentId: String) -> URL?

    /// Deletes downloaded attachment from disk and returns result of deleting
    ///
    /// - parameter attachmentId: id of attachment's file
    @discardableResult
    func delete(attachmentId: String) -> Bool

    /// Deletes all downloaded attachments from disk
    func clear()

    /// Add delegate to notify about download process
    ///
    /// - parameter delegate: Instance of delegate
    func add(delegate: KinescopeAttachmentDownloadableDelegate)

    /// Remove delegate
    ///
    /// - parameter delegate: Instance of delegate
    func remove(delegate: KinescopeAttachmentDownloadableDelegate)

    /// Restore all download tasks which were interrupted by app close
    func restore()

}
