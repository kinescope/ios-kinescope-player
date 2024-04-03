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
    
    /// Default link to share video and play it on web.
    public var shareLink: URL? {
        URL(string: "https://kinescope.io/\(videoId)")
    }

    /// - parameter videoId: Id of concrete video. For example from [GET Videos list](https://documenter.getpostman.com/view/10589901/TVCcXpNM)
    /// - parameter looped: If value is `true` show video in infinite loop. By default is `false`
    public init(videoId: String, looped: Bool = false) {
        self.videoId = videoId
        self.looped = looped
    }

}
