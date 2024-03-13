//
//  KinescopeVideoPlayStrategy.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 29.03.2021.
//

import AVFoundation

protocol PlayingStrategy {

    var player: AVPlayer { get }

    /// Set AVPlayerItem to `Player`
    ///
    /// - parameter item: AVPlayerItem with resource to play
    func bind(item: AVPlayerItem)

    /// Stop playing. Clear AVPlayer item
    func unbind()

    /// Start playing of video
    ///  - parameter rate: The rate at which to play the item.
    ///  Allowed values are between 0.0 and 2.0.
    func play(with rate: Float)

    /// Pause playing of video
    func pause()
}

extension PlayingStrategy {

    func play(with rate: Float) {
        player.rate = rate
    }

    func pause() {
        player.pause()
    }

}
