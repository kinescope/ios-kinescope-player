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

    /// A Swift package bundle has no version in its Info.plist, so the version comes from code.
    private let currentVersion = Kinescope.sdkVersion

    // MARK: - Factory

    func provide() -> T? {
        var result = T()
        result.version = currentVersion
        result.type = type
        return result
    }
}
