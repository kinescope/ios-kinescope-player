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

// MARK: - Builder

public class KinescopeSideMenuBarConfigurationBuilder {
    private var titleFont: UIFont
    private var titleColor: UIColor
    private var downloadAllFont: UIFont
    private var downloadAllColor: UIColor
    private var downloadAllHighlightedColor: UIColor
    private var iconSize: CGFloat
    private var preferedHeight: CGFloat
    
    public init(configuration: KinescopeSideMenuBarConfiguration = .default) {
        self.titleFont = configuration.titleFont
        self.titleColor = configuration.titleColor
        self.downloadAllFont = configuration.downloadAllFont
        self.downloadAllColor = configuration.downloadAllColor
        self.downloadAllHighlightedColor = configuration.downloadAllHighlightedColor
        self.iconSize = configuration.iconSize
        self.preferedHeight = configuration.preferedHeight
    }
    
    public func setTitleFont(_ titleFont: UIFont) -> Self {
        self.titleFont = titleFont
        return self
    }
    
    public func setTitleColor(_ titleColor: UIColor) -> Self {
        self.titleColor = titleColor
        return self
    }
    
    public func setDownloadAllFont(_ downloadAllFont: UIFont) -> Self {
        self.downloadAllFont = downloadAllFont
        return self
    }
    
    public func setDownloadAllColor(_ downloadAllColor: UIColor) -> Self {
        self.downloadAllColor = downloadAllColor
        return self
    }
    
    public func setDownloadAllHighlightedColor(_ downloadAllHighlightedColor: UIColor) -> Self {
        self.downloadAllHighlightedColor = downloadAllHighlightedColor
        return self
    }
    
    public func setIconSize(_ iconSize: CGFloat) -> Self {
        self.iconSize = iconSize
        return self
    }
    
    public func setPreferedHeight(_ preferedHeight: CGFloat) -> Self {
        self.preferedHeight = preferedHeight
        return self
    }
    
    public func build() -> KinescopeSideMenuBarConfiguration {
        return KinescopeSideMenuBarConfiguration(
            titleFont: titleFont,
            titleColor: titleColor,
            downloadAllFont: downloadAllFont,
            downloadAllColor: downloadAllColor,
            downloadAllHighlightedColor: downloadAllHighlightedColor,
            iconSize: iconSize,
            preferedHeight: preferedHeight
        )
    }
}
