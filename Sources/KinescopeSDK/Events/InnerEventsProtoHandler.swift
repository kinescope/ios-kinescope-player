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
    private let video = Analytics_Video()
    private let player = Analytics_Player()
    private let device = Analytics_Device()
    private let session = Analytics_Session()
    private let playback = Analytics_Playback()

    // MARK: - Init

    init(service: AnalyticsService) {
        self.service = service
    }
    
    // TODO: - add protocol to gather video, player, device, session and playback data
}

// MARK: - InnerEventsHandler

extension InnerEventsProtoHandler: InnerEventsHandler {
    
    func playback(sec: TimeInterval) {
        send(event: .playback, value: 0)
    }

    func play() {
        send(event: .play, value: 0)
    }

    func pause() {
        send(event: .pause, value: 0)
    }

    func end() {
        send(event: .end, value: 0)
    }

    func replay() {
        send(event: .replay, value: 0)
    }

    func buffer(sec: TimeInterval) {
        send(event: .buffering, value: 0)
    }

    func seek() {
        send(event: .seek, value: 0)
    }

    func rate(_ rate: Float) {
        send(event: .rate, value: 0)
    }

    func view() {
        send(event: .view, value: 0)
    }

    func enterfullscreen() {
        send(event: .enterfullscreen, value: 0)
    }

    func exitfullscreen() {
        send(event: .exitfullscreen, value: 0)
    }

    func qualitychanged(_ quality: String) {
        send(event: .qualitychanged, value: 0)
    }

    func autoqualitychanged(_ quality: String) {
        send(event: .autoqualitychanged, value: 0)
    }
}

// MARK: - Private

private extension InnerEventsProtoHandler {

    func send(event: InnerProtoEvent, value: Float) {
        service.send(event: build(event: event, value: value))
    }

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
