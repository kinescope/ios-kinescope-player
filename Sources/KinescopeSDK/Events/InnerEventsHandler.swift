//
//  InnerEventsHandler.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 27.04.2021.
//

import Foundation

public protocol InnerEventsHandler {
    func send(event: InnerProtoEvent, value: Float)
}

// MARK: - Defaults

extension InnerEventsHandler {
    func send(event: InnerProtoEvent) {
        send(event: event, value: 0)
    }
}
