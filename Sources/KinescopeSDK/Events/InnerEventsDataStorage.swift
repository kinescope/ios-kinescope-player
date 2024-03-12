//
//  InnerEventsDataStorage.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 12.03.2024.
//

import Foundation

protocol InnerEventsDataStorage {
    var video: VideoAnalyticDataFactory { get }
    var player: PlayerAnalyticDataFactory { get }
    var device: DeviceAnalyticDataFactory { get }
    var session: SessionAnalyticDataFactory { get }
    var playback: PlaybackAnalyticDataFactory { get }
}
