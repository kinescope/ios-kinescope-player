//
//  KinescopeServicesProvider.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//
// swiftlint:disable implicitly_unwrapped_optional

/// Provider of services working with kinescope api and events
public protocol KinescopeServicesProvider {

    /// Config for sdk
    var config: KinescopeConfig? { get }

    /// Service managing downloading of assets
    var assetDownloader: KinescopeAssetDownloadable! { get }

    /// Service managing downloading of videos
    var videoDownloader: KinescopeVideoDownloadable! { get }

    /// Service managing downloading of attachments
    var attachmentDownloader: KinescopeAttachmentDownloadable! { get }

    /// Service managing inspectations of dashboard content like videos, projects etc
    var inspector: KinescopeInspectable! { get }

    /// Service managing logging process
    var logger: KinescopeLogging? { get }

    /// Events center
    var eventsCenter: KinescopeEventsCenter! { get }

}
