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
    let timeIndicator: KinescopePlayerTimeindicatorConfiguration
    let timeline: KinescopePlayerTimelineConfiguration
    let optionsMenu: KinescopePlayerOptionsConfiguration

    /// - parameter tintColor: Tint Color of buttons and controls
    /// - parameter backgroundColor: Background color of panel
    /// - parameter preferedHeigh: Height of control panel in points.
    /// - parameter hideOnPlayTimeout: Can hide control panel when video is playing some time.
    /// Require value in seconds. Do not use big values.
    /// Set `nil` to keep control panel always visible.
    /// - parameter timeIndicator: Appearance of current tme indicator
    /// - parameter timeline: Appearance of timeline
    /// - parameter options: Appearance of expandable options menu
    public init(tintColor: UIColor,
                backgroundColor: UIColor,
                preferedHeigh: CGFloat,
                hideOnPlayTimeout: TimeInterval?,
                timeIndicator: KinescopePlayerTimeindicatorConfiguration,
                timeline: KinescopePlayerTimelineConfiguration,
                optionsMenu: KinescopePlayerOptionsConfiguration) {
        self.tintColor = tintColor
        self.backgroundColor = backgroundColor
        self.preferedHeigh = preferedHeigh
        self.hideOnPlayTimeout = hideOnPlayTimeout
        self.timeIndicator = timeIndicator
        self.timeline = timeline
        self.optionsMenu = optionsMenu
    }
}
