//
//  KinescopeLiveIndicatorConfiguration.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 01.03.2024.
//

import UIKit

/// Appearance preferences for live indicator
public struct KinescopeLiveIndicatorConfiguration {

    let titleFont: UIFont
    let titleColor: UIColor
    let circleRadius: CGFloat
    let onColor: UIColor
    let offColor: UIColor

    /// - Parameters:
    ///   - titleFont: font for live indicator text "isLive"
    ///   - titleColor: color for live indicator text "isLive"
    ///   - circleRadius: radius for live indicator circle
    ///   - onColor: color for live indicator animation when stream is online
    ///   - offColor: color for live indicator animation when stream is online
    public init(titleFont: UIFont,
                titleColor: UIColor,
                circleRadius: CGFloat,
                onColor: UIColor,
                offColor: UIColor) {
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.circleRadius = circleRadius
        self.onColor = onColor
        self.offColor = offColor
    }
}

// MARK: - Defaults

public extension KinescopeLiveIndicatorConfiguration {
    static let `default`: KinescopeLiveIndicatorConfiguration = .init(
        titleFont: .systemFont(ofSize: 14.0, weight: .medium),
        titleColor: UIColor.white.withAlphaComponent(0.32),
        circleRadius: 4,
        onColor: UIColor(red: 0.94, green: 0.31, blue: 0.39, alpha: 1),
        offColor: UIColor.white.withAlphaComponent(0.32)
    )
}
