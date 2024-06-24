//
//  EmptyBufferObserver.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 24.06.2024.
//

import Foundation
import AVFoundation

final class EmptyBufferObserver: KVOObserverFactory {

    private weak var playerBody: KinescopePlayerBody?
    private weak var repeater: Repeater?

    init(playerBody: KinescopePlayerBody,
         repeater: Repeater) {
        self.repeater = repeater
        self.playerBody = playerBody
    }

    func provide() -> NSKeyValueObservation? {
        playerBody?.strategy.player.currentItem?.observe(
            \.isPlaybackBufferEmpty,
            options: [.new, .old],
            changeHandler: { [weak self] item, value in
                let isBufferEmpty = value.newValue ?? item.isPlaybackBufferEmpty
                if isBufferEmpty {
                    self?.repeater?.start()
                }

                Kinescope.shared.logger?.log(
                    message: "AVPlayer.isPlaybackBufferEmpty – \(isBufferEmpty)",
                    level: KinescopeLoggerLevel.player
                )
            }
        )
    }

}

