//
//  KinescopePlayerConfigurable.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//

/// Control protocol for configuration of player
public protocol KinescopePlayerConfigurable {

    /// Set speed of video
    ///
    /// - parameter speed: Speed options enum
    func set(speed: KinescopePlayerSpeed)

    /// Set mute on player
    ///
    /// - parameter muted: `true` to mute, or` false` to unmmute
    func set(muted: Bool)

}
