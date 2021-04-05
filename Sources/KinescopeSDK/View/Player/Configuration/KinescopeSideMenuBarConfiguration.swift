//
//  KinescopeSideMenuConfiguration.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 02.04.2021.
//

import UIKit

/// Appearence preferences for sidemenu
public struct KinescopeSideMenuBarConfiguration {

    let titleFont: UIFont
    let titleColor: UIColor
    let iconSize: CGFloat
    let preferedHeight: CGFloat

    /// - Parameters:
    ///   - titleFont: Font for title
    ///   - titleColor: Color of title and buttons
    ///   - iconSize: Height of square button icons
    ///   - preferedHeight: Height of sidemenu navigation bar in points
    public init(titleFont: UIFont, titleColor: UIColor, iconSize: CGFloat, preferedHeight: CGFloat) {
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.iconSize = iconSize
        self.preferedHeight = preferedHeight
    }
}

// MARK: - Defaults

public extension KinescopeSideMenuBarConfiguration {
    static let `default`: KinescopeSideMenuBarConfiguration = .init(
        titleFont: .systemFont(ofSize: 14, weight: .medium),
        titleColor: .white,
        iconSize: 24,
        preferedHeight: 40
    )
}
