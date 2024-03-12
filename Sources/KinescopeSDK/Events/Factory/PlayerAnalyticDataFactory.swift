//
//  PlayerAnalyticDataFactory.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 12.03.2024.
//

import Foundation

final class PlayerAnalyticDataFactory: Factory {
    typealias T = Analytics_Player

    // MARK: - Properties
    
    private let type = "iOS SDK"
    private let bundle = Bundle(for: KinescopeVideoPlayer.self)
    private lazy var currentVersion = bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"

    // MARK: - Methods

    func provide() -> T? {
        var result = T()
        result.version = currentVersion
        result.type = type
        return result
    }
}
