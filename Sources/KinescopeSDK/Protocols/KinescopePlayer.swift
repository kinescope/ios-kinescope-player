//
//  KinescopePlayer.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 22.03.2021.
//

import AVKit

/// Control protocol for player
public protocol KinescopePlayer {

    /// - parameter videoId: Id of concrete video. For example from [GET Videos list](https://documenter.getpostman.com/view/10589901/TVCcXpNM)
    init(videoId: String)

    /// If value is `true` show video in infinite loop.
    ///
    /// - Warning: configure this property before attaching player to view
    var looped: Bool { get set }

    /// Start playing of video
    func play()

    /// Pause playing of video
    func pause()

    /// Stops playing video
    func stop()

    /// Generate new playerItem with selected quality resource
    ///
    /// - parameter quality: Quality of video to play.
    func select(quality: KinescopeVideoQuality)

    /// Bind player to view
    /// - Parameter view: view for binding
    func attach(view: KinescopePlayerView)

    /// Unbind player to view
    /// - Parameter view: view for unbinding
    func detach(view: KinescopePlayerView)
}
