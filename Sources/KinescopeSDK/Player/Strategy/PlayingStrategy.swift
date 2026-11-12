//
//  KinescopeVideoPlayStrategy.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 29.03.2021.
//

import AVFoundation

protocol PlayingStrategy {

    var player: AVPlayer { get }

    /// `true` when an item is already bound and still usable.
    /// A preparing item counts: `isReadyToPlay == false` does not mean the queue is empty.
    var hasBoundItem: Bool { get }

    /// `true` if strategy restarts item by itself when it reaches the end
    var isLooping: Bool { get }

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

    /// Let current item play to the end without restarting it
    func stopLooping()

    /// Allow strategy to restart items by itself again
    func startLooping()
}

extension PlayingStrategy {

    var hasBoundItem: Bool {
        guard let item = player.currentItem else {
            return false
        }
        return item.status != .failed
    }

    var isLooping: Bool {
        false
    }

    func play(with rate: Float) {
        player.rate = rate
    }

    func pause() {
        player.pause()
    }

    func stopLooping() { }

    func startLooping() { }

}
