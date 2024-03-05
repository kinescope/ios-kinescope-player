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
    private weak var repeater: Repeater?

    private var readyToPlayReceived: () -> Void

    init(playerBody: KinescopePlayerBody,
         repeater: Repeater,
         readyToPlayReceived: @escaping () -> Void) {
        self.playerBody = playerBody
        self.repeater = repeater
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
                    onSuccess()
                case .failed, .unknown:
                    Kinescope.shared.logger?.log(error: item.error,
                                                 level: KinescopeLoggerLevel.player)
                    onError()
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

// MARK: - Private

private extension CurrentItemStatusObserver {

    func onSuccess() {
        readyToPlayReceived()
        playerBody?.view?.overlay?.isHidden = false
    }

    func onError() {
        // TODO: - if playlist is empty then show live stream stub
        // otherwise
        tryRepeat()
    }

    func tryRepeat() {
        switch repeater?.start() {
        case .inProgress:
            playerBody?.view?.startLoader()
        case .limitReached, .none:
            playerBody?.view?.stopLoader(withPreview: false)
            // TODO: - show error stub with refresh button
        }
    }

}
