//
//  KinescopePlayer.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 22.03.2021.
//

import AVKit

/// Control protocol for player
public protocol KinescopePlayer {

    /// Delegate of Picture in Picture controller
    var pipDelegate: AVPictureInPictureControllerDelegate? { get set }

    var delegate: KinescopeVideoPlayerDelegate? { get set }

    /// - parameter config: player config
    init(config: KinescopePlayerConfig)

    /// Set video model model if it's already loaded
    func setVideo(_ video: KinescopeVideo)

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
