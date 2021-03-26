//
//  KinescopePlayer.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 22.03.2021.
//

import AVKit

/// Control protocol for player
public protocol KinescopePlayer {

    /// Uses for binding to playerView
    var avPlayer: AVPlayer { get }

    /// Uses for binding to playerView
    var delegate: KinescopePlayerDelegate? { get set }

    /// - parameter videoId: Id of concrete video. For example from [GET Videos list](https://documenter.getpostman.com/view/10589901/TVCcXpNM)
    /// - parameter looped: show video in infinite loop
    init(videoId: String, looped: Bool)

    /// Start playing of video
    func play()

    /// Pause playing of video
    func pause()
}
