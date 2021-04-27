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
    /// API endpoint
    let endpoint: String
    /// Analytics API endpoint
    let analyticsEndpoint: String

    /// - parameter apiKey: ApiKey from [dashboard](https://dashboard.kinescope.io/)
    /// - parameter endpoint: API endpoint
    /// - parameter endpoint: Analytics API endpoint
    public init(apiKey: String,
                endpoint: String = "https://api.kinescope.io/v1",
                analyticsEndpoint: String = "https://metrics.kinescope.io/player-native") {
        self.apiKey = apiKey
        self.endpoint = endpoint
        self.analyticsEndpoint = analyticsEndpoint
    }
}
