//
//  LoopedPlayingStrategy.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 29.03.2021.
//

import AVFoundation

/// Strategy to play item inside infinite loop.
final class LoopedPlayingStrategy: PlayingStrategy {

    private var queuePlayer = AVQueuePlayer()
    private var looper: AVPlayerLooper?
    private var templateURL: URL?
    private var isLoopingDisabled = false
    /// Loopers whose setup block may still be inserting into the queue they were given.
    /// Dropping them immediately lets that block run against the live queue.
    private var retired: [AVPlayerLooper] = []

    /// The live queue was replaced. The view and observers still point at `previous`.
    var onPlayerReplaced: ((_ previous: AVPlayer, _ current: AVPlayer) -> Void)?

    var player: AVPlayer {
        queuePlayer
    }

    var hasBoundItem: Bool {
        guard let looper else {
            return false
        }
        return looper.status == .unknown || looper.status == .ready
    }

    var isLooping: Bool {
        guard let looper, !isLoopingDisabled else {
            return false
        }
        return looper.status != .cancelled && looper.status != .failed
    }

    func bind(item: AVPlayerItem) {
        let url = (item.asset as? AVURLAsset)?.url
        if let looper, url == templateURL, looper.status == .unknown || looper.status == .ready {
            return
        }
        retireCurrentLooper()
        templateURL = url
        let handoff = installFreshQueue()
        let created = AVPlayerLooper(player: queuePlayer, templateItem: item)
        looper = created
        if isLoopingDisabled {
            created.disableLooping()
        } else if handoff.rate > 0 {
            queuePlayer.rate = handoff.rate
        }
        onPlayerReplaced?(handoff.previous, queuePlayer)
    }

    func unbind() {
        templateURL = nil
        guard looper != nil else {
            return
        }
        retireCurrentLooper()
        let handoff = installFreshQueue()
        onPlayerReplaced?(handoff.previous, queuePlayer)
    }

    func stopLooping() {
        isLoopingDisabled = true
        looper?.disableLooping()
    }

    func startLooping() {
        // AVPlayerLooper can't be re-enabled, so looping resumes with the next bound item.
        isLoopingDisabled = false
    }

    private func retireCurrentLooper() {
        guard let looper else {
            return
        }
        looper.disableLooping()
        retired.append(looper)
        self.looper = nil
        retired.removeAll { $0.status == .cancelled || $0.status == .failed }
    }

    /// A new looper needs an empty queue it alone will manage.
    /// The previous queue stays with the retired looper, whose setup may still be running.
    private func installFreshQueue() -> (previous: AVQueuePlayer, rate: Float) {
        let previous = queuePlayer
        let rate = previous.rate
        let fresh = AVQueuePlayer()
        fresh.volume = previous.volume
        fresh.isMuted = previous.isMuted
        fresh.preventsDisplaySleepDuringVideoPlayback = previous.preventsDisplaySleepDuringVideoPlayback
        previous.pause()
        queuePlayer = fresh
        return (previous, rate)
    }

}
