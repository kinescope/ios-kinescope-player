//
//  PlayerStatusObserver.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 26.02.2024.
//

import Foundation
import AVFoundation

final class PlayerStatusObserverFactory: KVOObserverFactory {

    private weak var playerBody: KinescopePlayerBody?

    init(playerBody: KinescopePlayerBody) {
        self.playerBody = playerBody
    }

    func provide() -> NSKeyValueObservation? {
        playerBody?.strategy.player.observe(
            \.status,
            options: [.new, .old],
            changeHandler: { [weak self] item, _ in
                self?.playerBody?.view?.change(status: item.status)

                Kinescope.shared.logger?.log(message: "AVPlayer.Status – \(item.status.debugDescription)",
                                             level: KinescopeLoggerLevel.player)
                self?.playerBody?.delegate?.player(changedStatusTo: item.status)
            }
        )
    }

}
