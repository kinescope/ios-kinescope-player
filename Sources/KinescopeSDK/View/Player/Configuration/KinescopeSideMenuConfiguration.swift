//
//  KinescopeSideMenuConfiguration.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 02.04.2021.
//

import UIKit

/// Appearence preferences for side menu with player settings
public struct KinescopeSideMenuConfiguration {

    let backgroundColor: UIColor
    let item: KinescopeSideMenuItemConfiguration
    let bar: KinescopeSideMenuBarConfiguration

    /// - parameter backgroundColor: Background color of menu
    /// - parameter item: Appearance for labels inside cells
    /// - parameter bar: Appearance of side menu navigation bar
    public init(backgroundColor: UIColor,
                item: KinescopeSideMenuItemConfiguration,
                bar: KinescopeSideMenuBarConfiguration) {
        self.backgroundColor = backgroundColor
        self.item = item
        self.bar = bar
    }
}

// MARK: - Defaults

public extension KinescopeSideMenuConfiguration {
    
    static func builder() -> KinescopeSideMenuConfigurationBuilder {
        .init(configuration: .default)
    }

    static let `default`: KinescopeSideMenuConfiguration = .init(
        backgroundColor: .init(red: 0.13, green: 0.13, blue: 0.13, alpha: 1),
        item: .default,
        bar: .default
    )
}

// MARK: - Builder

public class KinescopeSideMenuConfigurationBuilder {
    private var backgroundColor: UIColor = .black
    private var item: KinescopeSideMenuItemConfiguration = .default
    private var bar: KinescopeSideMenuBarConfiguration = .default

    public init(configuration: KinescopeSideMenuConfiguration = .default) {
        self.backgroundColor = configuration.backgroundColor
        self.item = configuration.item
        self.bar = configuration.bar
    }

    public func setBackgroundColor(_ color: UIColor) -> Self {
        self.backgroundColor = color
        return self
    }

    public func setItem(_ item: KinescopeSideMenuItemConfiguration) -> Self {
        self.item = item
        return self
    }

    public func setBar(_ bar: KinescopeSideMenuBarConfiguration) -> Self {
        self.bar = bar
        return self
    }

    public func build() -> KinescopeSideMenuConfiguration {
        .init(backgroundColor: backgroundColor,
              item: item,
              bar: bar)
    }
}
