//
//  AVPlayer+Debug.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 27.02.2024.
//

import AVFoundation

extension AVPlayer {

    var isReadyToPlay: Bool {
        return currentItem?.status == .readyToPlay
    }

}

extension AVPlayer.Status {

    var debugDescription: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .readyToPlay:
            return "readyToPlay"
        case .failed:
            return "failed"
        @unknown default:
            return "Unknown"
        }
    }

}

extension AVPlayerItem.Status {

    var debugDescription: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .readyToPlay:
            return "readyToPlay"
        case .failed:
            return "failed"
        @unknown default:
            return "Unknown"
        }
    }

}

extension AVPlayer.TimeControlStatus {

    var debugDescription: String {
        switch self {
        case .paused:
            return "paused"
        case .playing:
            return "playing"
        case .waitingToPlayAtSpecifiedRate:
            return "waitingToPlayAtSpecifiedRate"
        @unknown default:
            return "Unknown"
        }
    }

}

extension AVPlayer {

    var hasFiniteDuration: Bool {
        guard let duration = currentItem?.duration else {
            return false
        }

        return !duration.flags.contains(.indefinite) && duration.flags.contains(.valid)
    }

    var durationSeconds: Double? {
        if hasFiniteDuration {
            return currentItem?.duration.seconds
        } else {
            guard let lastRange = currentItem?.seekableTimeRanges.last?.timeRangeValue else {
                return 0
            }
            return lastRange.start.seconds + lastRange.duration.seconds
        }
    }

}

extension AVPlayerItem {

    var buferredSeconds: Double {
        loadedTimeRanges.first?.timeRangeValue.end.seconds ?? 0
    }

}
