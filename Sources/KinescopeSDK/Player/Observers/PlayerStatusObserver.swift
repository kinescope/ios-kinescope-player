//
//  PlayerStatusObserver.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 26.02.2024.
//

import Foundation
import AVFoundation

final class PlayerStatusObserver: KVOObserverFactory {

    private weak var playerBody: KinescopePlayerBody?
    private weak var repeater: Repeater?

    init(playerBody: KinescopePlayerBody,
         repeater: Repeater) {
        self.playerBody = playerBody
        self.repeater = repeater
    }

    func provide() -> NSKeyValueObservation? {
        playerBody?.strategy.player.observe(
            \.status,
            options: [.new, .old],
            changeHandler: { [weak self] item, _ in
                switch item.status {
                case .readyToPlay:
                    self?.onSuccess()
                case .failed, .unknown:
                    self?.onError(error: item.error)
                }

                Kinescope.shared.logger?.log(message: "AVPlayer.Status – \(item.status.debugDescription)",
                                             level: KinescopeLoggerLevel.player)
                self?.playerBody?.delegate?.player(changedStatusTo: item.status)
            }
        )
    }

}

// MARK: - Private

private extension PlayerStatusObserver {

    func onSuccess() {
        // do nothing
    }

    func onError(error: Error?) {
        tryRepeat(with: error)
    }

    func tryRepeat(with error: Error?) {
        switch repeater?.start() {
        case .inProgress:
            playerBody?.view?.startLoader()
        case .limitReached, .none:
            playerBody?.view?.stopLoader(withPreview: false)
            if let error {
                playerBody?.view?.errorOverlay?.display(error: error)
            }
        }
    }

}
