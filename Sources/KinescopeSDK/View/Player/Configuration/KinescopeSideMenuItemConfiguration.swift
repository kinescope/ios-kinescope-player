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

// MARK: - Builder

public class KinescopeSideMenuItemConfigurationBuilder {
    private var titleFont: UIFont
    private var titleColor: UIColor
    private var valueFont: UIFont
    private var valueColor: UIColor
    private var highlightedColor: UIColor
    
    public init(configuration: KinescopeSideMenuItemConfiguration) {
        self.titleFont = configuration.titleFont
        self.titleColor = configuration.titleColor
        self.valueFont = configuration.valueFont
        self.valueColor = configuration.valueColor
        self.highlightedColor = configuration.highlightedColor
    }
    
    public func setTitleFont(_ font: UIFont) -> Self {
        self.titleFont = font
        return self
    }
    
    public func setTitleColor(_ color: UIColor) -> Self {
        self.titleColor = color
        return self
    }
    
    public func setValueFont(_ font: UIFont) -> Self {
        self.valueFont = font
        return self
    }
    
    public func setValueColor(_ color: UIColor) -> Self {
        self.valueColor = color
        return self
    }
    
    public func setHighlightedColor(_ color: UIColor) -> Self {
        self.highlightedColor = color
        return self
    }
    
    public func build() -> KinescopeSideMenuItemConfiguration {
        .init(titleFont: titleFont,
              titleColor: titleColor,
              valueFont: valueFont,
              valueColor: valueColor,
              highlightedColor: highlightedColor)
    }
}
