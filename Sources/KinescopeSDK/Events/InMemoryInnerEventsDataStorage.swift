//
//  InMemoryInnerEventsDataStorage.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 12.03.2024.
//

import Foundation

protocol InnerEventsDataInputs {
    var videoInput: VideoAnalyticInput { get }
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

    init() {
        self.video = .init()
        self.player = .init()
        self.device = .init()
        self.session = .init()
        self.playback = .init()
    }
}

// MARK: - InnerEventsDataInputs

extension InMemoryInnerEventsDataStorage: InnerEventsDataInputs {
    var videoInput: VideoAnalyticInput {
        return video
    }

    var sessionInput: SessionAnalyticInput {
        return session
    }

    var playbackInput: PlaybackAnalyticInput {
        return playback
    }
}
