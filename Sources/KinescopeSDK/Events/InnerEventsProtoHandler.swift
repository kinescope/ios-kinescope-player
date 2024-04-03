//
//  InnerEventsProtoHandler.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 27.04.2021.
//

import Foundation

public enum InnerProtoEvent: String {
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
    private let dataStorage: InnerEventsDataStorage

    private var oneTimeEventsSet = Set<InnerProtoEvent>()

    // MARK: - Init

    init(service: AnalyticsService, dataStorage: InnerEventsDataStorage) {
        self.service = service
        self.dataStorage = dataStorage
    }
}

// MARK: - InnerEventsHandler

extension InnerEventsProtoHandler: InnerEventsHandler {
    func send(event: InnerProtoEvent, value: Float) {
        service.send(event: build(event: event, value: value))
    }

    func sendOnce(event: InnerProtoEvent, value: Float) {
        guard !oneTimeEventsSet.contains(event) else {
            return
        }
        oneTimeEventsSet.insert(event)
        send(event: event, value: value)
    }

    func reset() {
        oneTimeEventsSet.removeAll()
    }
}

// MARK: - Private

private extension InnerEventsProtoHandler {

    func build(event: InnerProtoEvent, value: Float) -> Analytics_Native {
        return Analytics_Native.with {
            $0.event = event.rawValue
            $0.value = value
            $0.video = dataStorage.video.provide() ?? .init()
            $0.player = dataStorage.player.provide() ?? .init()
            $0.device = dataStorage.device.provide() ?? .init()
            $0.session = dataStorage.session.provide() ?? .init()
            $0.playback = dataStorage.playback.provide() ?? .init()
            $0.eventTime = .init(date: Date())
            return
        }
    }

}
