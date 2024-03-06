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
                    onError(error: item.error)
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
        playerBody?.view?.stopLoader(withPreview: true)
        playerBody?.view?.announceSnack?.hideAnimated()
        playerBody?.view?.overlay?.isHidden = false
    }

    func onError(error: Error?) {
        // CoreMediaErrorDomain error -16190 means that live stream is not ready to play
        if let error = error as NSError?, error.code == -16190 {
            showLiveStub()
            tryRepeat(with: nil)
        } else {
            tryRepeat(with: error)
        }
    }
    
    func showLiveStub() {
        guard let video = playerBody?.video else {
            return
        }
        playerBody?.view?.announceSnack?.display(startsAt: video.live?.startsAt)
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
