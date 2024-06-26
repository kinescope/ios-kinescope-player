//
//  Manager.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 22.03.2021.
//
// swiftlint:disable implicitly_unwrapped_optional

/// Implementation of services
class Manager: KinescopeServicesProvider {

    // MARK: - Properties

    var config: KinescopeConfig!
    
    var drmFactory: DataProtectionHandlerFactory!

    var assetDownloader: KinescopeAssetDownloadable!

    var videoDownloader: KinescopeVideoDownloadable!

    var attachmentDownloader: KinescopeAttachmentDownloadable!

    var inspector: KinescopeInspectable!

    var analyticFactory: (any KinescopeAnalyticHandlerFactory)!

    var logger: KinescopeLogging?

}
