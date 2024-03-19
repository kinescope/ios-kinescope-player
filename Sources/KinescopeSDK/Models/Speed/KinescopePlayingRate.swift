//
//  KinescopePlayingRate.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 13.03.2024.
//

import Foundation

public enum KinescopePlayingRate: Float, CaseIterable {
    case oneQuarter = 0.25
    case oneHalf = 0.5
    case threeQuaters = 0.75
    case normal = 1
    case oneAndQuarter = 1.25
    case oneAndHalf = 1.5
    case oneAndThreeQuaters = 1.75
    case double = 2

    public var title: String {
        switch self {
        case .normal:
            return L10n.Player.normal
        default:
            return String(rawValue)
        }
    }

    public static func from(string: String) -> Self {
        return allCases.first(where: { string == $0.title }) ?? .normal
    }

}
