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
    /// `User-Agent` for video metadata, the stream, and subtitles, like `userAgent` in the web player embed.
    /// `nil` keeps the system value.
    public let userAgent: String?

    /// - parameter endpoint: Root endpoint of kinescope video service
    /// - parameter referer: Referer for header
    /// - parameter apiKey: Bearer token for the dashboard video list
    /// - parameter userAgent: `User-Agent` for metadata, stream, and subtitle requests. `nil` keeps the system value
    public init(endpoint: String = "https://kinescope.io/",
                referer: String = "https://kinescope.io/",
                apiKey: String? = nil,
                userAgent: String? = nil) {
        self.endpoint = endpoint
        self.referer = referer
        self.apiKey = apiKey
        let agent = userAgent?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.userAgent = (agent?.isEmpty == false) ? agent : nil
    }
}
