//
//  KinescopeConfig.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 22.03.2021.
//

/// Configuration entity required to connect SDK with your dashboard
public struct KinescopeConfig {

    /// ApiKey from [dashboard](https://dashboard.kinescope.io/)
    ///  Required only for private videos
    let apiKey: String?
    /// API endpoint
    let endpoint: String
    /// Referer for direct loading of public videos from kinescope
    let referer: String

    /// - parameter apiKey: ApiKey from [dashboard](https://dashboard.kinescope.io/)
    /// - parameter endpoint: API endpoint
    /// - parameter referer: Referer for header
    public init(apiKey: String?,
                endpoint: String = "https://api.kinescope.io/v1",
                referer: String = "https://kinescope.io/") {
        self.apiKey = apiKey
        self.endpoint = endpoint
        self.referer = referer
    }
}
