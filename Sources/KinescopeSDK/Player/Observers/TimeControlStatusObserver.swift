//
//  TimeControlStatusObserver.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 26.02.2024.
//

import Foundation
import AVFoundation

final class TimeControlStatusObserver: KVOObserverFactory {

    private weak var playerBody: KinescopePlayerBody?

    private var timeControlStatusChanged: (AVPlayer.TimeControlStatus) -> Void

    init(playerBody: KinescopePlayerBody,
         timeControlStatusChanged: @escaping (AVPlayer.TimeControlStatus) -> Void) {
        self.playerBody = playerBody
        self.timeControlStatusChanged = timeControlStatusChanged
    }

    func provide() -> NSKeyValueObservation? {
        playerBody?.strategy.player.observe(
            \.timeControlStatus,
            options: [.new, .old],
            changeHandler: { [weak self] item, _ in
                self?.timeControlStatusChanged(item.timeControlStatus)
                self?.playerBody?.view?.change(timeControlStatus: item.timeControlStatus)

                Kinescope.shared.logger?.log(
                    message: "AVPlayer.TimeControlStatus – \(item.timeControlStatus.debugDescription)",
                    level: KinescopeLoggerLevel.player
                )
                self?.playerBody?.delegate?.player(changedTimeControlStatusTo: item.timeControlStatus)
            }
        )
    }
}
