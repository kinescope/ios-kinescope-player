//
//  PlaybackTimePeriodicObserver.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 26.02.2024.
//

import Foundation
import AVFoundation

final class PlaybackTimePeriodicObserver: Factory {
    
    private let period: CMTime

    private weak var playerBody: KinescopePlayerBody?

    private var secondsPlayed: (Double) -> Void

    init(period: CMTime,
         playerBody: KinescopePlayerBody,
         secondsPlayed: @escaping (Double) -> Void) {
        self.period = period
        self.playerBody = playerBody
        self.secondsPlayed = secondsPlayed
    }

    func provide() -> Any? {
        playerBody?.strategy.player.addPeriodicTimeObserver(forInterval: period,
                                                            queue: .main) { [weak self] time in
            guard let self else {
                return
            }
            
            guard let currentItem = playerBody?.strategy.player.currentItem else {
                return
            }

            let duration = playerBody?.strategy.player.durationSeconds
            let isLive = playerBody?.isLive ?? false
            let played: TimeInterval = {
                guard let duration, duration.isFinite, duration > 0 else {
                    return time.seconds
                }
                return isLive ? duration : min(duration, time.seconds)
            }()
            secondsPlayed(played)

            playerBody?.delegate?.player(playbackPositionMovedTo: time.seconds)

            guard let controlPanel = playerBody?.view?.controlPanel,
                  let duration, duration.isFinite, duration > 0 else {
                return
            }
            
            // Preload observation
            
            let buferredTime = currentItem.buferredSeconds
            playerBody?.delegate?.player(playbackBufferMovedTo: buferredTime)
            
            let bufferProgress = CGFloat(buferredTime / duration)
            
            if !bufferProgress.isNaN {
                controlPanel.setBufferred(progress: bufferProgress)
            }
        }
    }

}
