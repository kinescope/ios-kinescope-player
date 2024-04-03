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

// MARK: - Builder

public class KinescopeControlPanelConfigurationBuilder {
    private var tintColor: UIColor
    private var backgroundColor: UIColor
    private var preferedHeight: CGFloat
    private var hideOnPlayTimeout: TimeInterval?
    private var liveIndicator: KinescopeLiveIndicatorConfiguration
    private var timeIndicator: KinescopePlayerTimeindicatorConfiguration
    private var timeline: KinescopePlayerTimelineConfiguration
    private var optionsMenu: KinescopePlayerOptionsConfiguration

    public init(configuration: KinescopeControlPanelConfiguration = .default) {
        self.tintColor = configuration.tintColor
        self.backgroundColor = configuration.backgroundColor
        self.preferedHeight = configuration.preferedHeight
        self.hideOnPlayTimeout = configuration.hideOnPlayTimeout
        self.liveIndicator = configuration.liveIndicator
        self.timeIndicator = configuration.timeIndicator
        self.timeline = configuration.timeline
        self.optionsMenu = configuration.optionsMenu
    }

    public func setTintColor(_ color: UIColor) -> Self {
        self.tintColor = color
        return self
    }

    public func setBackgroundColor(_ color: UIColor) -> Self {
        self.backgroundColor = color
        return self
    }

    public func setPreferedHeight(_ height: CGFloat) -> Self {
        self.preferedHeight = height
        return self
    }

    public func setHideOnPlayTimeout(_ timeout: TimeInterval?) -> Self {
        self.hideOnPlayTimeout = timeout
        return self
    }

    public func setLiveIndicator(_ configuration: KinescopeLiveIndicatorConfiguration) -> Self {
        self.liveIndicator = configuration
        return self
    }

    public func setTimeIndicator(_ configuration: KinescopePlayerTimeindicatorConfiguration) -> Self {
        self.timeIndicator = configuration
        return self
    }

    public func setTimeline(_ configuration: KinescopePlayerTimelineConfiguration) -> Self {
        self.timeline = configuration
        return self
    }

    public func setOptionsMenu(_ configuration: KinescopePlayerOptionsConfiguration) -> Self {
        self.optionsMenu = configuration
        return self
    }

    public func build() -> KinescopeControlPanelConfiguration {
        return .init(tintColor: tintColor,
                     backgroundColor: backgroundColor,
                     preferedHeight: preferedHeight,
                     hideOnPlayTimeout: hideOnPlayTimeout,
                     liveIndicator: liveIndicator,
                     timeIndicator: timeIndicator,
                     timeline: timeline,
                     optionsMenu: optionsMenu)
    }
}
