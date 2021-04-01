//
//  KinescopePlayerTimelineConfiguration.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 31.03.2021.
//

import UIKit

/// Appearence preferences for timeline
public struct KinescopePlayerTimelineConfiguration {

    let activeColor: UIColor
    let inactiveColor: UIColor
    let lineHeight: CGFloat
    let circleRadius: CGFloat

    /// - parameter activeColor: Color of circle and line before. Equal to past time or played video part.
    /// - parameter inactiveColor: Color of line after circle. Equal to future or not played video part.
    /// - parameter lineHeight: Height of line in points
    /// - parameter circleRadius: Radius of current position circle
    public init(activeColor: UIColor,
                inactiveColor: UIColor,
                lineHeight: CGFloat,
                circleRadius: CGFloat) {
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
        self.lineHeight = lineHeight
        self.circleRadius = circleRadius
    }
}

// MARK: - Defaults

public extension KinescopePlayerTimelineConfiguration {

    static let `default`: KinescopePlayerTimelineConfiguration = {
        .init(activeColor: UIColor(red: 0.38, green: 0.38, blue: 0.988, alpha: 1),
            inactiveColor: UIColor(red: 1, green: 1, blue: 1, alpha: 0.32),
            lineHeight: 4,
            circleRadius: 8)
    }()

}
