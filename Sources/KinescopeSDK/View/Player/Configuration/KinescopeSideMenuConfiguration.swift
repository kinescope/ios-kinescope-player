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
    let bar: KinescopeSideMenuBarConfiguration

    /// - parameter backgroundColor: Background color of menu
    /// - parameter bar: Appearance of side menu navigation bar
    public init(backgroundColor: UIColor,
                bar: KinescopeSideMenuBarConfiguration) {
        self.backgroundColor = backgroundColor
        self.bar = bar
    }
}

// MARK: - Defaults

public extension KinescopeSideMenuConfiguration {
    static let `default`: KinescopeSideMenuConfiguration = .init(
        backgroundColor: .init(red: 0.13, green: 0.13, blue: 0.13, alpha: 0.32),
        bar: .default
    )
}
