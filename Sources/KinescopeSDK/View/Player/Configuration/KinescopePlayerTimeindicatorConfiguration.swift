//
//  KinescopePlayerTimeindicatorConfiguration.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 31.03.2021.
//

import UIKit

/// Appearence preferences for time indicator
public struct KinescopePlayerTimeindicatorConfiguration {
    
    let color: UIColor
    let fontSize: CGFloat
    let showsDuration: Bool
    
    /// - parameter color: Color of label with time value
    /// - parameter fontSize: Font size of label with time value
    /// - parameter showsDuration: Tap reveals total duration next to the current time (`0:12 / 10:00`).
    public init(color: UIColor,
                fontSize: CGFloat,
                showsDuration: Bool = true) {
        self.color = color
        self.fontSize = fontSize
        self.showsDuration = showsDuration
    }
}

// MARK: - Defaults

public extension KinescopePlayerTimeindicatorConfiguration {
    
    static func builder() -> KinescopePlayerTimeindicatorConfigurationBuilder {
        .init(configuration: .default)
    }

    static let `default`: KinescopePlayerTimeindicatorConfiguration = .init(color: .white,
                                                                            fontSize: 14)
    
}

// MARK: - Builder

public class KinescopePlayerTimeindicatorConfigurationBuilder {
    private var color: UIColor
    private var fontSize: CGFloat
    private var showsDuration: Bool
    
    public init(configuration: KinescopePlayerTimeindicatorConfiguration = .default) {
        self.color = configuration.color
        self.fontSize = configuration.fontSize
        self.showsDuration = configuration.showsDuration
    }
    
    public func setColor(_ color: UIColor) -> Self {
        self.color = color
        return self
    }
    
    public func setFontSize(_ fontSize: CGFloat) -> Self {
        self.fontSize = fontSize
        return self
    }

    public func setShowsDuration(_ showsDuration: Bool) -> Self {
        self.showsDuration = showsDuration
        return self
    }
    
    public func build() -> KinescopePlayerTimeindicatorConfiguration {
        .init(color: color,
              fontSize: fontSize,
              showsDuration: showsDuration)
    }
}
