//
//  KinescopeAnnounceConfiguration.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 06.03.2024.
//

import UIKit

/// Appearance preferences for announcement snack
public struct KinescopeAnnounceConfiguration {

    let image: UIImage
    let titleFont: UIFont
    let titleColor: UIColor
    let subtitleFont: UIFont
    let subtitleColor: UIColor
    let backgroundColor: UIColor

    /// - parameter image: image icon for announcement snack
    /// - parameter titleFont: font for announcement title
    /// - parameter titleColor: color for announcement title
    /// - parameter subtitleFont: font for announcement subtitle
    /// - parameter subtitleColor: color for announcement subtitle
    public init(image: UIImage,
                titleFont: UIFont,
                titleColor: UIColor,
                subtitleFont: UIFont,
                subtitleColor: UIColor,
                backgroundColor: UIColor) {
        self.image = image
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.subtitleFont = subtitleFont
        self.subtitleColor = subtitleColor
        self.backgroundColor = backgroundColor
    }
}

// MARK: - Defaults

public extension KinescopeAnnounceConfiguration {
    
    static func builder() -> KinescopeAnnounceConfigurationBuilder {
        .init(configuration: .default)
    }

    static let `default`: KinescopeAnnounceConfiguration = .init(
        image: UIImage.image(named: "announce"),
        titleFont: .systemFont(ofSize: 16, weight: .medium),
        titleColor: .white,
        subtitleFont: .systemFont(ofSize: 14, weight: .regular),
        subtitleColor: .white,
        backgroundColor: .init(red: 0.13, green: 0.13, blue: 0.13, alpha: 0.8)
    )
}

// MARK: - Builder

public class KinescopeAnnounceConfigurationBuilder {
    private var image: UIImage = UIImage()
    private var titleFont: UIFont = UIFont.systemFont(ofSize: 14)
    private var titleColor: UIColor = .black
    private var subtitleFont: UIFont = UIFont.systemFont(ofSize: 12)
    private var subtitleColor: UIColor = .gray
    private var backgroundColor: UIColor = .white

    public init(configuration: KinescopeAnnounceConfiguration = .default) {
        self.image = configuration.image
        self.titleFont = configuration.titleFont
        self.titleColor = configuration.titleColor
        self.subtitleFont = configuration.subtitleFont
        self.subtitleColor = configuration.subtitleColor
        self.backgroundColor = configuration.backgroundColor
    }

    public func setImage(_ image: UIImage) -> Self {
        self.image = image
        return self
    }

    public func setTitleFont(_ font: UIFont) -> Self {
        self.titleFont = font
        return self
    }

    public func setTitleColor(_ color: UIColor) -> Self {
        self.titleColor = color
        return self
    }

    public func setSubtitleFont(_ font: UIFont) -> Self {
        self.subtitleFont = font
        return self
    }

    public func setSubtitleColor(_ color: UIColor) -> Self {
        self.subtitleColor = color
        return self
    }

    public func setBackgroundColor(_ color: UIColor) -> Self {
        self.backgroundColor = color
        return self
    }

    public func build() -> KinescopeAnnounceConfiguration {
        return KinescopeAnnounceConfiguration(
            image: image,
            titleFont: titleFont,
            titleColor: titleColor,
            subtitleFont: subtitleFont,
            subtitleColor: subtitleColor,
            backgroundColor: backgroundColor
        )
    }
}
