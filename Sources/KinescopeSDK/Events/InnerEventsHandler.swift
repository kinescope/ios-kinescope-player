//
//  InnerEventsHandler.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 27.04.2021.
//

import Foundation

public protocol InnerEventsHandler {
    func sendOnce(event: InnerProtoEvent, value: Float)
    func send(event: InnerProtoEvent, value: Float)
    func reset()
}

// MARK: - Defaults

extension InnerEventsHandler {
    func send(event: InnerProtoEvent) {
        send(event: event, value: 0)
    }

    func sendOnce(event: InnerProtoEvent) {
        sendOnce(event: event, value: 0)
    }
}
