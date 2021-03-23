//
//  Manager.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 22.03.2021.
//

/// Implementation of services
class Manager: KinescopeServicesProvider {

    // MARK: - Properties

    var config: KinescopeConfig?

    var downloader: KinescopeDownloadable!

    var inspector: KinescopeInspectable!
}


