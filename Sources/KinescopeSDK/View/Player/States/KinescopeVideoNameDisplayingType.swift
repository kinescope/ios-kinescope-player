//
//  Kinescope.swift
//  KinescopeSDK
//
//  Created by Никита Гагаринов on 04.05.2021.
//

import Foundation

/// Type of displaying view with title and description of video
public enum KinescopeVideoNameDisplayingType {
    case always
    case hidesWithOverlay
    case never

    /// Converts alpha depending on current type
    func convertAlpha(from currentAlpha: CGFloat) -> CGFloat {
        switch self {
        case .always:
            return 1.0
        case .hidesWithOverlay:
            return currentAlpha
        case .never:
            return 0.0
        }
    }

}
