//
//  KinescopePlayerOptionsConfiguration.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 31.03.2021.
//

import UIKit

/// Appearence preferences for expandable menu with options
public struct KinescopePlayerOptionsConfiguration {

    let normalColor: UIColor
    let highlightedColor: UIColor
    let iconSize: CGFloat

    /// - parameter normalColor: Normal color of option button icons
    /// - parameter highlightedColor: Highlighted color of option button icons
    /// - parameter iconSize: Height of square button icons
    public init(normalColor: UIColor,
                highlightedColor: UIColor,
                iconSize: CGFloat) {
        self.normalColor = normalColor
        self.highlightedColor = highlightedColor
        self.iconSize = iconSize
    }
}

// MARK: - Defaults

public extension KinescopePlayerOptionsConfiguration {

    static let `default`: KinescopePlayerOptionsConfiguration = .init(normalColor: .white,
                                                                      highlightedColor: .gray,
                                                                      iconSize: 24)

}
