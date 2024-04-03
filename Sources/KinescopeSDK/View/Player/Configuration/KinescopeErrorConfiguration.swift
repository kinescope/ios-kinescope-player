//
//  KinescopeErrorConfiguration.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 06.03.2024.
//

import UIKit

/// Appearance preferences for live indicator
public struct KinescopeErrorConfiguration {

    let image: UIImage
    let titleFont: UIFont
    let titleColor: UIColor
    let subtitleFont: UIFont
    let subtitleColor: UIColor
    let buttonTtileFont: UIFont
    let buttonTitleColor: UIColor
    let buttonColor: UIColor
    let backgroundColor: UIColor

    /// - parameter image: image icon for error view
    /// - parameter titleFont: font for error title
    /// - parameter titleColor: color for error title
    /// - parameter subtitleFont: font for error subtitle
    /// - parameter subtitleColor: color for error subtitle
    /// - parameter buttonTtileFont: font for error button title
    /// - parameter buttonTitleColor: color for error button title
    /// - parameter buttonColor: color for error button
    /// - parameter backgroundColor: background color for error view
    public init(image: UIImage,
                titleFont: UIFont,
                titleColor: UIColor,
                subtitleFont: UIFont,
                subtitleColor: UIColor,
                buttonTtileFont: UIFont,
                buttonTitleColor: UIColor,
                buttonColor: UIColor,
                backgroundColor: UIColor) {
        self.image = image
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.subtitleFont = subtitleFont
        self.subtitleColor = subtitleColor
        self.buttonTtileFont = buttonTtileFont
        self.buttonTitleColor = buttonTitleColor
        self.buttonColor = buttonColor
        self.backgroundColor = backgroundColor
    }
}

// MARK: - Defaults

public extension KinescopeErrorConfiguration {

    static let `default`: KinescopeErrorConfiguration = .init(
        image: UIImage.image(named: "warn"),
        titleFont: .systemFont(ofSize: 16, weight: .medium),
        titleColor: .white,
        subtitleFont: .systemFont(ofSize: 14, weight: .regular),
        subtitleColor: .white.withAlphaComponent(0.64),
        buttonTtileFont: .systemFont(ofSize: 14, weight: .medium),
        buttonTitleColor: .white,
        buttonColor: .white.withAlphaComponent(0.08),
        backgroundColor: .init(red: 0.13, green: 0.13, blue: 0.13, alpha: 0.8)
    )

}

// MARK: - Builder

public class KinescopeErrorConfigurationBuilder {
    private var image: UIImage = UIImage.image(named: "warn")
    private var titleFont: UIFont = .systemFont(ofSize: 16, weight: .medium)
    private var titleColor: UIColor = .white
    private var subtitleFont: UIFont = .systemFont(ofSize: 14, weight: .regular)
    private var subtitleColor: UIColor = .white.withAlphaComponent(0.64)
    private var buttonTitleFont: UIFont = .systemFont(ofSize: 14, weight: .medium)
    private var buttonTitleColor: UIColor = .white
    private var buttonColor: UIColor = .white.withAlphaComponent(0.08)
    private var backgroundColor: UIColor = .init(red: 0.13, green: 0.13, blue: 0.13, alpha: 0.8)

    public init(configuration: KinescopeErrorConfiguration = .default) {
        self.image = configuration.image
        self.titleFont = configuration.titleFont
        self.titleColor = configuration.titleColor
        self.subtitleFont = configuration.subtitleFont
        self.subtitleColor = configuration.subtitleColor
        self.buttonTitleFont = configuration.buttonTtileFont
        self.buttonTitleColor = configuration.buttonTitleColor
        self.buttonColor = configuration.buttonColor
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

    public func setButtonTitleFont(_ font: UIFont) -> Self {
        self.buttonTitleFont = font
        return self
    }

    public func setButtonTitleColor(_ color: UIColor) -> Self {
        self.buttonTitleColor = color
        return self
    }

    public func setButtonColor(_ color: UIColor) -> Self {
        self.buttonColor = color
        return self
    }

    public func setBackgroundColor(_ color: UIColor) -> Self {
        self.backgroundColor = color
        return self
    }

    public func build() -> KinescopeErrorConfiguration {
        return KinescopeErrorConfiguration(
            image: image,
            titleFont: titleFont,
            titleColor: titleColor,
            subtitleFont: subtitleFont,
            subtitleColor: subtitleColor,
            buttonTtileFont: buttonTitleFont,
            buttonTitleColor: buttonTitleColor,
            buttonColor: buttonColor,
            backgroundColor: backgroundColor
        )
    }
}
