//
//  KinescopeVideoPlaySingleStrategy.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 29.03.2021.
//

import AVFoundation

/// Strategy to play item from start to end
final class KinescopeVideoPlaySingleStrategy: KinescopeVideoPlayStrategy {

    let player = AVPlayer()

    func bind(item: AVPlayerItem) {
        player.replaceCurrentItem(with: item)
    }

    func unbind() {
        player.replaceCurrentItem(with: nil)
    }
}
