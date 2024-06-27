//
//  CurrentItemObserver.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 16.06.2024.
//

import Foundation
import AVFoundation

final class CurrentItemObserver: KVOObserverFactory {
    
    private weak var playerBody: KinescopePlayerBody?
    
    private var currentItemChanged: (AVPlayerItem?) -> Void

    init(playerBody: KinescopePlayerBody,
         currentItemChanged: @escaping (AVPlayerItem?) -> Void) {
        self.playerBody = playerBody
        self.currentItemChanged = currentItemChanged
    }

    func provide() -> NSKeyValueObservation? {
        playerBody?.strategy.player.observe(
            \.currentItem,
            options: [.new, .old],
            changeHandler: { [weak self] item, _ in
                self?.currentItemChanged(item.currentItem)

                Kinescope.shared.logger?.log(
                    message: "AVPlayer.CurrentItem – \(item.currentItem.debugDescription)",
                    level: KinescopeLoggerLevel.player
                )
            }
        )
    }

}
