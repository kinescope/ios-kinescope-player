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

    static func builder() -> KinescopeLiveIndicatorConfigurationBuilder {
        .init(configuration: .default)
    }

    static let `default`: KinescopeLiveIndicatorConfiguration = .init(
        titleFont: .systemFont(ofSize: 14.0, weight: .medium),
        titleColor: UIColor.white.withAlphaComponent(0.32),
        circleRadius: 4,
        onColor: UIColor(red: 0.94, green: 0.31, blue: 0.39, alpha: 1),
        offColor: UIColor.white.withAlphaComponent(0.32)
    )
}

// MARK: - Builder

public class KinescopeLiveIndicatorConfigurationBuilder {
    private var titleFont: UIFont
    private var titleColor: UIColor
    private var circleRadius: CGFloat
    private var onColor: UIColor
    private var offColor: UIColor
    
    public init(configuration: KinescopeLiveIndicatorConfiguration) {
        self.titleFont = configuration.titleFont
        self.titleColor = configuration.titleColor
        self.circleRadius = configuration.circleRadius
        self.onColor = configuration.onColor
        self.offColor = configuration.offColor
    }
    
    public func setTitleFont(_ titleFont: UIFont) -> Self {
        self.titleFont = titleFont
        return self
    }
    
    public func setTitleColor(_ titleColor: UIColor) -> Self {
        self.titleColor = titleColor
        return self
    }
    
    public func setCircleRadius(_ circleRadius: CGFloat) -> Self {
        self.circleRadius = circleRadius
        return self
    }
    
    public func setOnColor(_ onColor: UIColor) -> Self {
        self.onColor = onColor
        return self
    }
    
    public func setOffColor(_ offColor: UIColor) -> Self {
        self.offColor = offColor
        return self
    }
    
    public func build() -> KinescopeLiveIndicatorConfiguration {
        return .init(titleFont: titleFont,
                     titleColor: titleColor,
                     circleRadius: circleRadius,
                     onColor: onColor,
                     offColor: offColor)
    }
}
