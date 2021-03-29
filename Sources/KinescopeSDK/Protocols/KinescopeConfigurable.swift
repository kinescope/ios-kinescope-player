//
//  KinescopeConfigurable.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 22.03.2021.
//

/// Control protocol supporting connection between SDK and dashboard
public protocol KinescopeConfigurable {

    /// - parameter config: Configuration parameters required to connection
    func setConfig(_ config: KinescopeConfig)

    /// - parameter logingTypes: Types of logging events
    func set(logingTypes: [KinescopeLoggingType])
}
