//
//  TimeControlStatusObserver.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 26.02.2024.
//

import Foundation
import AVFoundation

final class TimeControlStatusObserver: KVOObserverFactory {

    private weak var player: AVPlayer?
    private weak var view: KinescopePlayerView?
    private weak var delegate: KinescopeVideoPlayerDelegate?

    private var timeControlStatusChanged: (AVPlayer.TimeControlStatus) -> Void

    init(player: AVPlayer?,
         view: KinescopePlayerView?,
         delegate: KinescopeVideoPlayerDelegate?,
         timeControlStatusChanged: @escaping (AVPlayer.TimeControlStatus) -> Void) {
        self.player = player
        self.view = view
        self.delegate = delegate
        self.timeControlStatusChanged = timeControlStatusChanged
    }

    func provide() -> NSKeyValueObservation? {
        player?.observe(
            \.timeControlStatus,
            options: [.new, .old],
            changeHandler: { [weak self] item, _ in
                self?.timeControlStatusChanged(item.timeControlStatus)
                self?.view?.change(timeControlStatus: item.timeControlStatus)

                Kinescope.shared.logger?.log(
                    message: "AVPlayer.TimeControlStatus – \(item.timeControlStatus.rawValue)",
                    level: KinescopeLoggerLevel.player
                )
                self?.delegate?.player(changedTimeControlStatusTo: item.timeControlStatus)
            }
        )
    }
}
