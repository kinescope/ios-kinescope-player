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
    let downloadAllFont: UIFont
    let downloadAllColor: UIColor
    let downloadAllHighlightedColor: UIColor
    let iconSize: CGFloat
    let preferedHeight: CGFloat

    /// - Parameters:
    ///   - titleFont: Font for title
    ///   - titleColor: Color of title and buttons
    ///   - downloadAllFont: Font for Download all button
    ///   - downloadAllColor: Color of Download all button
    ///   - downloadAllHighlightedColor: Press state color of Download all button
    ///   - iconSize: Height of square button icons
    ///   - preferedHeight: Height of sidemenu navigation bar in points
    public init(titleFont: UIFont,
                titleColor: UIColor,
                downloadAllFont: UIFont,
                downloadAllColor: UIColor,
                downloadAllHighlightedColor: UIColor,
                iconSize: CGFloat,
                preferedHeight: CGFloat) {
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.downloadAllFont = downloadAllFont
        self.downloadAllColor = downloadAllColor
        self.downloadAllHighlightedColor = downloadAllHighlightedColor
        self.iconSize = iconSize
        self.preferedHeight = preferedHeight
    }

}

// MARK: - Defaults

public extension KinescopeSideMenuBarConfiguration {
    static let `default`: KinescopeSideMenuBarConfiguration = .init(
        titleFont: .systemFont(ofSize: 14, weight: .medium),
        titleColor: .white,
        downloadAllFont: .systemFont(ofSize: 12.0),
        downloadAllColor: UIColor.white.withAlphaComponent(0.64),
        downloadAllHighlightedColor: UIColor.white.withAlphaComponent(0.5),
        iconSize: 24,
        preferedHeight: 40
    )
}
