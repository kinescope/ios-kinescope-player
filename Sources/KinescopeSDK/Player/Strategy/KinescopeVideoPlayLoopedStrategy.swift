//
//  KinescopeVideoPlayLoopedStrategy.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 29.03.2021.
//

import AVFoundation

/// Strategy to play item inside infinite loop.
final class KinescopeVideoPlayLoopedStrategy: KinescopeVideoPlayStrategy {

    private let queuePlayer = AVQueuePlayer()
    private var looper: AVPlayerLooper?

    var player: AVPlayer {
        queuePlayer
    }

    func bind(item: AVPlayerItem) {
        looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
    }

    func unbind() {
        looper = nil
    }

}
