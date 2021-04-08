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

    var config: KinescopeConfig?

    var assetDownloader: KinescopeAssetDownloadable!

    var inspector: KinescopeInspectable!

    var logger: KinescopeLogging?
}
