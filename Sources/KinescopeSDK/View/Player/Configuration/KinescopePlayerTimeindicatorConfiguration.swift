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
    
    /// - parameter color: Color of label with time value
    /// - parameter fontSize: Font size of label with time value
    public init(color: UIColor,
                fontSize: CGFloat) {
        self.color = color
        self.fontSize = fontSize
    }
}

// MARK: - Defaults

public extension KinescopePlayerTimeindicatorConfiguration {
    
    static let `default`: KinescopePlayerTimeindicatorConfiguration = .init(color: .white,
                                                                            fontSize: 14)
    
}

// MARK: - Builder

public class KinescopePlayerTimeindicatorConfigurationBuilder {
    private var color: UIColor
    private var fontSize: CGFloat
    
    public init(configuration: KinescopePlayerTimeindicatorConfiguration = .default) {
        self.color = configuration.color
        self.fontSize = configuration.fontSize
    }
    
    public func setColor(_ color: UIColor) -> Self {
        self.color = color
        return self
    }
    
    public func setFontSize(_ fontSize: CGFloat) -> Self {
        self.fontSize = fontSize
        return self
    }
    
    public func build() -> KinescopePlayerTimeindicatorConfiguration {
        .init(color: color,
              fontSize: fontSize)
    }
}
