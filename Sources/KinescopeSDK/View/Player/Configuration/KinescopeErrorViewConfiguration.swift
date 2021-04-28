//
//  KinescopeErrorViewConfiguration.swift
//  KinescopeSDK
//
//  Created by Никита Гагаринов on 27.04.2021.
//

import UIKit

/// Appearence preferences for timeline
public struct KinescopeErrorViewConfiguration {

    let backgroundColor: UIColor
    let image: UIImage
    let titleColor: UIColor
    let titleFont: UIFont
    let subtitleColor: UIColor
    let subtitleFont: UIFont
    let refreshTitleColor: UIColor
    let refreshTitleFont: UIFont
    let refreshCornerRadius: CGFloat
    let refreshBorderColor: UIColor
    let refreshBorderWidth: CGFloat

    /// - parameter backgroundColor: Color for background
    /// - parameter image: image for error state
    /// - parameter titleColor: Text color of title label
    /// - parameter titleFont: Text font of title label
    /// - parameter subtitleColor: Text color of subtitle label
    /// - parameter subtitleFont: Text font of subtitle label
    /// - parameter refreshTitleColor: Text color of refresh button
    /// - parameter refreshTitleFont: Text font of refresh button
    /// - parameter refreshCornerRadius: Corner radius of refresh button in points
    /// - parameter refreshBorderColor: Color of refresh button border
    /// - parameter refreshBorderWidth: Width of refresh button border in points
    public init(backgroundColor: UIColor,
                image: UIImage,
                titleColor: UIColor,
                titleFont: UIFont,
                subtitleColor: UIColor,
                subtitleFont: UIFont,
                refreshTitleColor: UIColor,
                refreshTitleFont: UIFont,
                refreshCornerRadius: CGFloat = 4,
                refreshBorderColor: UIColor,
                refreshBorderWidth: CGFloat = 1) {
        self.backgroundColor = backgroundColor
        self.image = image
        self.titleColor = titleColor
        self.titleFont = titleFont
        self.subtitleColor = subtitleColor
        self.subtitleFont = subtitleFont
        self.refreshTitleColor = refreshTitleColor
        self.refreshTitleFont = refreshTitleFont
        self.refreshCornerRadius = refreshCornerRadius
        self.refreshBorderColor = refreshBorderColor
        self.refreshBorderWidth = refreshBorderWidth
    }
}

// MARK: - Defaults

public extension KinescopeErrorViewConfiguration {

    static let `default`: KinescopeErrorViewConfiguration = {
        .init(backgroundColor: UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1),
              image: UIImage.image(named: "errorAttention"),
              titleColor: .white,
              titleFont: .systemFont(ofSize: 16, weight: .medium),
              subtitleColor: UIColor.white.withAlphaComponent(0.64),
              subtitleFont: .systemFont(ofSize: 14, weight: .regular),
              refreshTitleColor: .white,
              refreshTitleFont: .systemFont(ofSize: 14, weight: .semibold),
              refreshBorderColor: UIColor.white.withAlphaComponent(0.32))
    }()

}
