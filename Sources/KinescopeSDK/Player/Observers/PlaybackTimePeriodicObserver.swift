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
            
            /// Does not make sense without control panel and curremtItem
            guard let controlPanel = playerBody?.view?.controlPanel,
                  let currentItem = playerBody?.strategy.player.currentItem,
                  let duration = playerBody?.strategy.player.durationSeconds,
                  let isLive = playerBody?.isLive else {
                return
            }

            secondsPlayed(isLive ? duration : min(duration, time.seconds))

            Kinescope.shared.logger?.log(message: "playback position changed to \(time) seconds", level: KinescopeLoggerLevel.player)
            playerBody?.delegate?.player(playbackPositionMovedTo: time.seconds)
            
            // Preload observation
            
            let buferredTime = currentItem.loadedTimeRanges.first?.timeRangeValue.end.seconds ?? 0
            Kinescope.shared.logger?.log(message: "playback buffered \(buferredTime) seconds", level: KinescopeLoggerLevel.player)
            playerBody?.delegate?.player(playbackBufferMovedTo: time.seconds)
            
            let bufferProgress = CGFloat(buferredTime / duration)
            
            if !bufferProgress.isNaN {
                controlPanel.setBufferred(progress: bufferProgress)
            }
        }
    }

}
