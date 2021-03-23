//
//  KinescopePlayerConfigurable.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//

/// Control protocol for configuration of player
public protocol KinescopePlayerConfigurable {

    /// Set volume of video
    ///
    /// - parameter volume: A value of `0.0` indicates silence; a value of `1.0` (the default) indicates full audio volume for the player instance.
    func setVolume(_ volume: Float)

    /// Set speed of video
    ///
    /// - parameter speed: A value of `0.0` pauses the video, while a value of `1.0` plays the current item at its natural rate.
    /// Valle **less** than `1.0` will play slow forward. Value **greater** than `1.0` will play fast forward.
    /// - Warning: Negative values not supported.
    func setSpeed(_ speed: Float)

    /// Set loop playing. It means, video will start playing after end
    ///
    /// - parameter enabled: `true` to enable loop, or` false` to disable
    func setLoop(enabled: Bool)

}
