//
//  KinescopePlayer.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 22.03.2021.
//

/// Control protocol for player
public protocol KinescopePlayer {

    /// - parameter videoId: Id of concrete video. For example from [GET Videos list](https://documenter.getpostman.com/view/10589901/TVCcXpNM)
    init(videoId: String)

    /// Start playing of video
    func play()

    /// Stop playing of video
    func stop()
}
