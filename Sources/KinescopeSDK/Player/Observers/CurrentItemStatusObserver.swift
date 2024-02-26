//
//  CurrentItemStatusObserver.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 26.02.2024.
//

import Foundation
import AVFoundation

final class CurrentItemStatusObserver: KVOObserverFactory {
    
    private weak var player: AVPlayer?
    private weak var delegate: KinescopeVideoPlayerDelegate?

    private var readyToPlayReceived: () -> Void

    init(player: AVPlayer?,
         delegate: KinescopeVideoPlayerDelegate?,
         readyToPlayReceived: @escaping () -> Void) {
        self.player = player
        self.delegate = delegate
        self.readyToPlayReceived = readyToPlayReceived
    }

    func provide() -> NSKeyValueObservation? {
        player?.currentItem?.observe(
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
                    Kinescope.shared.logger?.log(message: "AVPlayerItem.error – \(String(describing: item.error))",
                                                 level: KinescopeLoggerLevel.player)
                default:
                    break
                }

                Kinescope.shared.logger?.log(message: "AVPlayerItem.Status – \(item.status)",
                                             level: KinescopeLoggerLevel.player)
                delegate?.player(changedItemStatusTo: item.status)
            }
        )
    }

}
