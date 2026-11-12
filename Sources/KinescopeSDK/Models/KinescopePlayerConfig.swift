//
//  KinescopePlayerConfig.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 29.03.2021.
//

import Foundation

/// Configuration entity required to connect resource with player
public struct KinescopePlayerConfig {

    /// Id of concrete video. For example from [GET Videos list](https://documenter.getpostman.com/view/10589901/TVCcXpNM)
    public let videoId: String

    /// If value is `true` show video in infinite loop.
    public let looped: Bool
    
    /// Repeating mode for player
    public let repeatingMode: RepeatingMode

    /// Local file URL for offline playback (e.g. downloaded video). When set, player uses this URL instead of streaming.
    public let localPlaybackURL: URL?

    /// Token for DRM-protected videos which require authorization on key server.
    /// Sent as `drmauthtoken` query parameter of video metadata request.
    public let drmAuthToken: String?

    /// Default link to share video and play it on web.
    public var shareLink: URL? {
        URL(string: "https://kinescope.io/\(videoId)")
    }

    /// - parameter videoId: Id of concrete video. For example from [GET Videos list](https://documenter.getpostman.com/view/10589901/TVCcXpNM)
    /// - parameter looped: If value is `true` show video in infinite loop. By default is `false`
    /// - parameter repeatingMode: Mode which will be used to repeat failed requests.
    /// - parameter localPlaybackURL: Optional local file URL for offline playback (e.g. downloaded video with or without DRM).
    /// - parameter drmAuthToken: Optional token for DRM-protected videos with authorization.
    public init(videoId: String,
                looped: Bool = false,
                repeatingMode: RepeatingMode = .default,
                localPlaybackURL: URL? = nil,
                drmAuthToken: String? = nil) {
        self.videoId = KinescopeVideoID.parse(videoId)
        self.looped = looped
        self.repeatingMode = repeatingMode
        self.localPlaybackURL = localPlaybackURL
        self.drmAuthToken = drmAuthToken
    }

}

/// Accepts a bare id or a Kinescope link (`https://kinescope.io/…`, `/embed/…`, `.json`).
enum KinescopeVideoID {

    private static let skippedPathParts: Set<String> = [
        "embed", "video", "watch", "player", "share", "v", "live", "e"
    ]

    static func parse(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return trimmed
        }
        let candidate = trimmed.contains("://")
            ? trimmed
            : (trimmed.lowercased().contains("kinescope.") ? "https://\(trimmed)" : trimmed)
        guard candidate.contains("://"),
              let components = URLComponents(string: candidate),
              let host = components.host?.lowercased(),
              host.contains("kinescope") else {
            return strip(trimmed)
        }
        var parts = components.path
            .split(separator: "/")
            .map { strip(String($0)) }
            .filter { !$0.isEmpty && !skippedPathParts.contains($0.lowercased()) }
        if let last = parts.last?.lowercased(),
           last.hasSuffix(".m3u8") || last == "playlist" || last == "master" {
            parts.removeLast()
        }
        return parts.last ?? strip(trimmed)
    }

    private static func strip(_ value: String) -> String {
        var text = value
        if let query = text.firstIndex(of: "?") {
            text = String(text[..<query])
        }
        if let hash = text.firstIndex(of: "#") {
            text = String(text[..<hash])
        }
        if text.lowercased().hasSuffix(".json") {
            text.removeLast(5)
        }
        return text
    }

}
