//
//  KinescopeSideMenuItemConfiguration.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 05.04.2021.
//

import UIKit

/// Appearence preferences for labels inside SideMenu cells
public struct KinescopeSideMenuItemConfiguration {

    let titleFont: UIFont
    let titleColor: UIColor
    let valueFont: UIFont
    let valueColor: UIColor
    let highlightedColor: UIColor

    /// - Parameters:
    ///   - titleFont: font for left aligned label
    ///   - titleColor: color for left aligned label
    ///   - valueFont: font for right aligned label
    ///   - valueColor: color for right aligned label
    ///   - highlightedColor: color for press state
    public init(titleFont: UIFont,
                titleColor: UIColor,
                valueFont: UIFont,
                valueColor: UIColor,
                highlightedColor: UIColor) {
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.valueFont = valueFont
        self.valueColor = valueColor
        self.highlightedColor = highlightedColor
    }
}

// MARK: - Defaults

public extension KinescopeSideMenuItemConfiguration {
    static let `default`: KinescopeSideMenuItemConfiguration = .init(
        titleFont: .systemFont(ofSize: 14.0, weight: .regular),
        titleColor: .white,
        valueFont: .systemFont(ofSize: 12.0),
        valueColor: UIColor.white.withAlphaComponent(0.64),
        highlightedColor: UIColor.white.withAlphaComponent(0.08)
    )
}
