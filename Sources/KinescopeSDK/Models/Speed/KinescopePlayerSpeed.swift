//
//  KinescopePlayerSpeed.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 25.05.2021.
//

import Foundation

public enum KinescopePlayerSpeed: Float, CaseIterable {
    case oneQuarter = 0.25
    case oneHalf = 0.5
    case threeQuaters = 0.75
    case normal = 1
    case oneAndQuarter = 1.25
    case oneAndHalf = 1.5
    case oneAndThreeQuaters = 1.75
    case double = 2

    public func toString() -> String {
        switch self {
        case .normal:
            return L10n.Player.normal
        default:
            return String(rawValue)
        }
    }

    public static func from(string: String) -> Self? {
        for speed in allCases {
            if speed.toString() == string {
                return speed
            }
        }
        return nil
    }

}
