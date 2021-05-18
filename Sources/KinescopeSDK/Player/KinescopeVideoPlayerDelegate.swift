//
//  KinescopeVideoPlayerDelegate.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 22.04.2021.
//

import AVFoundation

public protocol KinescopeVideoPlayerDelegate: AnyObject {
    /// Triggered on successfull play action
    func playerDidPlay()
    /// Triggered on video load finish with error(error == nil means no error)
    func playerDidLoadVideo(error: Error?)
    /// Triggered on pause action
    func playerDidPause()
    /// Triggered on stop action
    func playerDidStop()
    /// Triggered on AVPlayer playback position change
    func player(playbackPositionMovedTo time: TimeInterval)
    /// Triggered on AVPlayer buffer position change
    func player(playbackBufferMovedTo time: TimeInterval)
    /// Triggered on AVPlayer status change
    func player(changedStatusTo status: AVPlayer.Status)
    /// Triggered on AVPlayer item status change
    func player(changedItemStatusTo status: AVPlayerItem.Status)
    /// Triggered on AVPlayer TimeControlStatus change
    func player(changedTimeControlStatusTo status: AVPlayer.TimeControlStatus)
    /// Triggered on AVPlayer PresentationSize change
    func player(changedPresentationSizeTo size: CGSize)
    /// Triggered on force seek to time
    func player(didSeekTo time: TimeInterval)
    /// Triggered on scrabbing along timeline
    func player(timelinePositionMovedTo position: Double)
    /// Triggered on fast forward action
    func player(didFastForwardTo time: TimeInterval)
    /// Triggered on fast backward action
    func player(didFastBackwardTo time: TimeInterval)
    /// Triggered on quality change
    func player(changedQualityTo quality: String)
    /// Triggered on phone call actions
    func didGetCall(callState: KinescopeCallState)
}

public extension KinescopeVideoPlayerDelegate {
    func playerDidPlay() { }
    func playerDidLoadVideo(error: Error?) { }
    func playerDidPause() { }
    func playerDidStop() { }
    func player(playbackPositionMovedTo time: TimeInterval) { }
    func player(playbackBufferMovedTo time: TimeInterval) { }
    func player(changedStatusTo status: AVPlayer.Status) { }
    func player(changedItemStatusTo status: AVPlayerItem.Status) { }
    func player(changedTimeControlStatusTo status: AVPlayer.TimeControlStatus) { }
    func player(changedPresentationSizeTo size: CGSize) { }
    func player(didSeekTo time: TimeInterval) { }
    func player(timelinePositionMovedTo position: Double) { }
    func player(didFastForwardTo time: TimeInterval) { }
    func player(didFastBackwardTo time: TimeInterval) { }
    func player(changedQualityTo quality: String) { }
    func didGetCall(callState: KinescopeCallState) { }
}
