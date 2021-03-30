//
//  KinescopeControlPanelConfiguration.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 30.03.2021.
//

import UIKit

/// Appearence preferences for control panel with timeline and settings buttons
public struct KinescopeControlPanelConfiguration {

    let tintColor: UIColor
    let backgroundColor: UIColor
    let preferedHeigh: CGFloat
    let hideOnPlayTimeout: TimeInterval?

    /// - parameter tintColor: Tint Color of buttons and controls
    /// - parameter backgroundColor: Background color of panel
    /// - parameter preferedHeigh: Height of control panel in points.
    /// - parameter hideOnPlayTimeout: Can hide control panel when video is playing some time.
    /// Require value in seconds. Do not use big values.
    /// Set `nil` to keep control panel always visible.
    public init(tintColor: UIColor,
                backgroundColor: UIColor,
                preferedHeigh: CGFloat,
                hideOnPlayTimeout: TimeInterval?) {
        self.tintColor = tintColor
        self.backgroundColor = backgroundColor
        self.preferedHeigh = preferedHeigh
        self.hideOnPlayTimeout = hideOnPlayTimeout
    }
}
