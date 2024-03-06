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

    static let `default`: KinescopeAnnounceConfiguration = .init(
        image: UIImage.image(named: "announce"),
        titleFont: .systemFont(ofSize: 16, weight: .medium),
        titleColor: .white,
        subtitleFont: .systemFont(ofSize: 14, weight: .regular),
        subtitleColor: .white,
        backgroundColor: .init(red: 0.13, green: 0.13, blue: 0.13, alpha: 0.8)
    )
}
