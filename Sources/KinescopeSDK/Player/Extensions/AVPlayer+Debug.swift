//
//  AVPlayer+Debug.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 27.02.2024.
//

import AVFoundation

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
