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

class InnerEventsProtoHandler: InnerEventsHandler {

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

    // MARK: - Internal Methods

    // MARK: - InnerEventsHandler

    func playback(sec: TimeInterval) {
        service.send(event: build(event: .playback, value: Float(sec))) { _ in

        }
    }

    func play() {
        service.send(event: build(event: .play, value: 0)) { _ in

        }
    }

    func pause() {
        service.send(event: build(event: .pause, value: 0)) { _ in

        }
    }

    func end() {
        service.send(event: build(event: .end, value: 0)) { _ in

        }
    }

    func replay() {
        service.send(event: build(event: .replay, value: 0)) { _ in

        }
    }

    func buffer(sec: TimeInterval) {
        service.send(event: build(event: .buffering, value: Float(sec))) { _ in

        }
    }

    func seek() {
        service.send(event: build(event: .seek, value: 0)) { _ in

        }
    }

    func rate(_ rate: Float) {
        service.send(event: build(event: .rate, value: Float(rate))) { _ in

        }
    }

    func view() {
        service.send(event: build(event: .view, value: 0)) { _ in

        }
    }

    func enterfullscreen() {
        service.send(event: build(event: .enterfullscreen, value: 0)) { _ in

        }
    }

    func exitfullscreen() {
        service.send(event: build(event: .exitfullscreen, value: 0)) { _ in

        }
    }

    func qualitychanged() {
        service.send(event: build(event: .qualitychanged, value: 0)) { _ in

        }
    }

    func autoqualitychanged() {
        service.send(event: build(event: .autoqualitychanged, value: 0)) { _ in

        }
    }
    
}

// MARK: - Private

private extension InnerEventsProtoHandler {

    func send(event: InnerProtoEvent, value: Float) {
        service.send(event: build(event: event, value: value)) { _ in
            
        }
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
