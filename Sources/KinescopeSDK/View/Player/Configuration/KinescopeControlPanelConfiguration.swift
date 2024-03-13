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
    let preferedHeight: CGFloat
    let hideOnPlayTimeout: TimeInterval?
    let timeIndicator: KinescopePlayerTimeindicatorConfiguration
    let liveIndicator: KinescopeLiveIndicatorConfiguration
    let timeline: KinescopePlayerTimelineConfiguration
    let optionsMenu: KinescopePlayerOptionsConfiguration

    /// - parameter tintColor: Tint Color of buttons and controls
    /// - parameter backgroundColor: Background color of panel
    /// - parameter preferedHeight: Height of control panel in points.
    /// - parameter hideOnPlayTimeout: Can hide control panel when video is playing some time.
    /// Require value in seconds. Do not use big values.
    /// Set `nil` to keep control panel always visible.
    /// - parameter timeIndicator: Appearence preferences for live indicator
    /// - parameter timeIndicator: Appearance of current tme indicator
    /// - parameter timeline: Appearance of timeline
    /// - parameter options: Appearance of expandable options menu
    public init(tintColor: UIColor,
                backgroundColor: UIColor,
                preferedHeight: CGFloat,
                hideOnPlayTimeout: TimeInterval?,
                liveIndicator: KinescopeLiveIndicatorConfiguration,
                timeIndicator: KinescopePlayerTimeindicatorConfiguration,
                timeline: KinescopePlayerTimelineConfiguration,
                optionsMenu: KinescopePlayerOptionsConfiguration) {
        self.tintColor = tintColor
        self.backgroundColor = backgroundColor
        self.preferedHeight = preferedHeight
        self.hideOnPlayTimeout = hideOnPlayTimeout
        self.liveIndicator = liveIndicator
        self.timeIndicator = timeIndicator
        self.timeline = timeline
        self.optionsMenu = optionsMenu
    }
}

// MARK: - Defaults

public extension KinescopeControlPanelConfiguration {

    static let `default`: KinescopeControlPanelConfiguration = .init(
        tintColor: .gray,
        backgroundColor: .clear,
        preferedHeight: 40,
        hideOnPlayTimeout: 2,
        liveIndicator: .default,
        timeIndicator: .default,
        timeline: .default,
        optionsMenu: .default
    )

}
