//
//  InnerEventsProtoHandler.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 27.04.2021.
//

import Foundation

enum InnerProtoEvent: String {
    case playback
    case play
    case pause
    case end
    case replay
    case buffering
    case seek
    case rate
    case view
    case enterfullscreen
    case exitfullscreen
    case qualitychanged
    case autoqualitychanged
}

class InnerEventsProtoHandler {

    // MARK: - Properties

    private let service: AnalyticsService

    private var video = Analytics_Video()
    private var player = Analytics_Player()
    private var device = Analytics_Device()
    private var session = Analytics_Session()
    private var playback = Analytics_Playback()

    // MARK: - Init

    init(service: AnalyticsService) {
        self.service = service
    }
    
    // TODO: - add protocol to gather video, player, device, session and playback data
}

// MARK: - InnerEventsHandler

extension InnerEventsProtoHandler: InnerEventsHandler {
    func send(event: InnerProtoEvent, value: Float) {
        service.send(event: build(event: event, value: value))
    }
}

// MARK: - Private

private extension InnerEventsProtoHandler {

    func build(event: InnerProtoEvent, value: Float) -> Analytics_Native {
        return Analytics_Native.with {
            $0.event = event.rawValue
            $0.value = value
            $0.video = video
            $0.player = player
            $0.device = device
            $0.session = session
            $0.playback = playback
            $0.eventTime = .init()
            return
        }
    }

}
