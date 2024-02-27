//
//  CurrentItemStatusObserver.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 26.02.2024.
//

import Foundation
import AVFoundation

final class CurrentItemStatusObserver: KVOObserverFactory {
    
    private weak var playerBody: KinescopePlayerBody?

    private var readyToPlayReceived: () -> Void

    init(playerBody: KinescopePlayerBody,
         readyToPlayReceived: @escaping () -> Void) {
        self.playerBody = playerBody
        self.readyToPlayReceived = readyToPlayReceived
    }

    func provide() -> NSKeyValueObservation? {
        playerBody?.strategy.player.currentItem?.observe(
            \.status,
            options: [.new, .old],
            changeHandler: { [weak self] item, _ in
                guard let self else {
                    return
                }

                switch item.status {
                case .readyToPlay:
                    readyToPlayReceived()
                case .failed, .unknown:
                    Kinescope.shared.logger?.log(error: item.error,
                                                 level: KinescopeLoggerLevel.player)
                default:
                    break
                }

                Kinescope.shared.logger?.log(message: "AVPlayerItem.Status – \(item.status.debugDescription)",
                                             level: KinescopeLoggerLevel.player)
                playerBody?.delegate?.player(changedItemStatusTo: item.status)
            }
        )
    }

}
