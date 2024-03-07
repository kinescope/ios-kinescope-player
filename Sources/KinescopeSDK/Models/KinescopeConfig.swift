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
    /// Key server
    let keyServer: String

    /// - parameter endpoint: Root endpoint of kinescope video service
    /// - parameter referer: Referer for header
    public init(endpoint: String = "https://kinescope.io/",
                referer: String = "https://kinescope.io/",
                keyServer: String = "https://license.kinescope.io/v1/vod/") {
        self.endpoint = endpoint
        self.referer = referer
        self.keyServer = keyServer
    }
}
