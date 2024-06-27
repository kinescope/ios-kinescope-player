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

    /// Default link to share video and play it on web.
    public var shareLink: URL? {
        URL(string: "https://kinescope.io/\(videoId)")
    }

    /// - parameter videoId: Id of concrete video. For example from [GET Videos list](https://documenter.getpostman.com/view/10589901/TVCcXpNM)
    /// - parameter looped: If value is `true` show video in infinite loop. By default is `false`
    /// - parameter repeatingMode: Mode which will be used to repeat failed requests.
    public init(videoId: String, looped: Bool = false, repeatingMode: RepeatingMode = .default) {
        self.videoId = videoId
        self.looped = looped
        self.repeatingMode = repeatingMode
    }

}
