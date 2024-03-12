//
//  SessionAnalyticDataFactory.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 12.03.2024.
//

import Foundation

protocol SessionAnalyticInput {
    func refreshViewId()
    func setWatchedDuration(_ duration: Double)
}

final class SessionAnalyticDataFactory: Factory {
    typealias T = Analytics_Session
    
    // MARK: - Properties
    
    private let playerId = UUID().uuidString
    private var viewId = UUID().uuidString
    private var watchedDuration: Double?

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
}

// MARK: - SessionAnalyticInput

extension SessionAnalyticDataFactory: SessionAnalyticInput {
    func refreshViewId() {
        viewId = UUID().uuidString
    }
    
    func setWatchedDuration(_ duration: Double) {
        watchedDuration = duration
    }
}
