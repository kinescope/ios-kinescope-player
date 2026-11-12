//
//  KinescopeConfig.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 22.03.2021.
//

/// Configuration entity required to connect SDK with your dashboard
public struct KinescopeConfig {

    /// Root endpoint
    let endpoint: String
    /// Referer for direct loading of public videos from kinescope
    let referer: String
    /// Dashboard token for `api.kinescope.io`. Playback of a public video does not need it.
    public let apiKey: String?

    /// - parameter endpoint: Root endpoint of kinescope video service
    /// - parameter referer: Referer for header
    /// - parameter apiKey: Bearer token for the dashboard video list
    public init(endpoint: String = "https://kinescope.io/",
                referer: String = "https://kinescope.io/",
                apiKey: String? = nil) {
        self.endpoint = endpoint
        self.referer = referer
        self.apiKey = apiKey
    }
}
