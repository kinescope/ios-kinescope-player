//
//  SessionAnalyticDataFactory.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 12.03.2024.
//

import Foundation

protocol SessionAnalyticInput {
    func refreshViewId()
    func resetWatchedDuration()
    func incrementWatchedDuration(by step: TimeInterval)
}

final class SessionAnalyticDataFactory: Factory {
    typealias T = Analytics_Session
    
    // MARK: - Properties
    
    private let playerId = UUID().uuidString
    private var viewId = UUID().uuidString
    private var watchedDuration: TimeInterval?

    // MARK: - Factory

    func provide() -> T? {
        var result = T()
        if let id = playerId.data(using: .utf8) {
            result.id = id
        }
        if let viewID = viewId.data(using: .utf8) {
            result.viewID = viewID
        }
        result.type = Analytics_SessionType.online
        if let watchedDuration {
            result.watchedDuration = UInt32(watchedDuration)
        }
        return result
    }

    // MARK: - Other Methods

    func isWatchingMoreThen(threshold: TimeInterval) -> Bool {
        return watchedDuration ?? 0 > threshold
    }

    func isWatchingIn(interval: TimeInterval) -> Bool {
        guard let watchedDuration else {
            return false
        }
        let reminder = watchedDuration.truncatingRemainder(dividingBy: interval)
        // check that reminder in range close to 0
        return reminder <= 0.01
    }
}

// MARK: - SessionAnalyticInput

extension SessionAnalyticDataFactory: SessionAnalyticInput {
    func refreshViewId() {
        viewId = UUID().uuidString
    }
    
    func resetWatchedDuration() {
        watchedDuration = 0
    }

    func incrementWatchedDuration(by step: TimeInterval) {
        watchedDuration? += step
    }
}
