//
//  PlayerStatusObserver.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 26.02.2024.
//

import Foundation
import AVFoundation

final class PlayerStatusObserverFactory: KVOObserverFactory {

    private weak var player: AVPlayer?
    private weak var view: KinescopePlayerView?
    private weak var delegate: KinescopeVideoPlayerDelegate?

    init(player: AVPlayer?, view: KinescopePlayerView?, delegate: KinescopeVideoPlayerDelegate?) {
        self.player = player
        self.view = view
        self.delegate = delegate
    }

    func provide() -> NSKeyValueObservation? {
        player?.observe(
            \.status,
            options: [.new, .old],
            changeHandler: { [weak self] item, _ in
                self?.view?.change(status: item.status)

                Kinescope.shared.logger?.log(message: "AVPlayer.Status – \(item.status)",
                                             level: KinescopeLoggerLevel.player)
                self?.delegate?.player(changedStatusTo: item.status)
            }
        )
    }

}
