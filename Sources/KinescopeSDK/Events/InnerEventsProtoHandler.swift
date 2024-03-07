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
        
    }

    func play() {
        
    }

    func pause() {

    }

    func end() {

    }

    func replay() {

    }

    func buffer(sec: TimeInterval) {

    }

    func seek() {

    }

    func rate(_ rate: Float) {

    }

    func view() {

    }

    func enterfullscreen() {

    }

    func exitfullscreen() {

    }

    func qualitychanged(_ quality: String) {

    }

    func autoqualitychanged(_ quality: String) {

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
