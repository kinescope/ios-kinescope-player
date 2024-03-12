//
//  SessionAnalyticDataFactory.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 12.03.2024.
//

import Foundation

final class SessionAnalyticDataFactory: Factory {
    typealias T = Analytics_Session
    
    // MARK: - Properties
    
    // TODO: - keep one playerId for screen with many views
    private let playerId = UUID().uuidString
    private let viewId = UUID().uuidString

    // MARK: - Methods

    func provide() -> T? {
        var result = T()
        if let id = playerId.data(using: .utf8) {
            result.id = id
        }
        if let viewID = viewId.data(using: .utf8) {
            result.viewID = viewID
        }
        result.type = Analytics_SessionType.online
        // TODO: - add watched duration
//        result.watchedDuration = ??
        return result
    }
}
