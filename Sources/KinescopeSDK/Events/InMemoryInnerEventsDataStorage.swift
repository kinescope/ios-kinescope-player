//
//  InMemoryInnerEventsDataStorage.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 12.03.2024.
//

import Foundation

protocol InnerEventsDataInputs {
    var sessionInput: SessionAnalyticInput { get }
    var playbackInput: PlaybackAnalyticInput { get }
}

final class InMemoryInnerEventsDataStorage: InnerEventsDataStorage {
    // MARK: - Properties

    private(set) var video: VideoAnalyticDataFactory

    private(set) var player: PlayerAnalyticDataFactory

    private(set) var device: DeviceAnalyticDataFactory

    private(set) var session: SessionAnalyticDataFactory

    private(set) var playback: PlaybackAnalyticDataFactory

    // MARK: - Init

    init(video: VideoAnalyticDataFactory, player: PlayerAnalyticDataFactory, device: DeviceAnalyticDataFactory, session: SessionAnalyticDataFactory, playback: PlaybackAnalyticDataFactory) {
        self.video = video
        self.player = player
        self.device = device
        self.session = session
        self.playback = playback
    }
}

// MARK: - InnerEventsDataInputs

extension InMemoryInnerEventsDataStorage: InnerEventsDataInputs {
    var sessionInput: SessionAnalyticInput {
        return session
    }

    var playbackInput: PlaybackAnalyticInput {
        return playback
    }
}
