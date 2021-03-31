//
//  KinescopePlayerOptionsConfiguration.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 31.03.2021.
//

import UIKit

/// Appearence preferences for control panel with timeline and settings buttons
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
