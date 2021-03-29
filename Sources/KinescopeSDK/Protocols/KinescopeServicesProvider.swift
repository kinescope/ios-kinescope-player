//
//  KinescopeServicesProvider.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//
// swiftlint:disable implicitly_unwrapped_optional

/// Provider of services working with kinescope api
public protocol KinescopeServicesProvider {

    /// Service managing downloading of assets
    var downloader: KinescopeDownloadable! { get }

    /// Service managing inspectations of dashboard content like videos, projects etc
    var inspector: KinescopeInspectable! { get }

    /// Service managing logging process
    var logger: KinescopeLogging! { get }

}
