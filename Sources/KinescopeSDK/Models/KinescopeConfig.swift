//
//  KinescopeConfig.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 22.03.2021.
//

/// Configuration entity required to connect SDK with your dashboard
public struct KinescopeConfig {

    /// ApiKey from [dashboard](https://dashboard.kinescope.io/)
    let apiKey: String

    /// - parameter apiKey: ApiKey from [dashboard](https://dashboard.kinescope.io/)
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
}
