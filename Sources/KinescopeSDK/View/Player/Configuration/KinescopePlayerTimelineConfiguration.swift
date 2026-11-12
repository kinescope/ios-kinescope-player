//
//  KinescopePlayerTimelineConfiguration.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 31.03.2021.
//

import UIKit

/// Appearence preferences for timeline
public struct KinescopePlayerTimelineConfiguration {
    
    let activeColor: UIColor
    let inactiveColor: UIColor
    let bufferedColor: UIColor
    let lineHeight: CGFloat
    let circleRadius: CGFloat
    let draggingCircleRadius: CGFloat
    
    /// - parameter activeColor: Color of circle and line before. Equal to past time or played video part.
    /// - parameter inactiveColor: Color of line after circle. Equal to future or not played video part.
    /// - parameter bufferedColor: Color of already loaded but not played part.
    /// - parameter lineHeight: Height of line in points
    /// - parameter circleRadius: Radius of current position circle. `0` hides circle when not dragging.
    /// - parameter draggingCircleRadius: Radius of position circle while user drags timeline.
    public init(activeColor: UIColor,
                inactiveColor: UIColor,
                bufferedColor: UIColor = UIColor.white.withAlphaComponent(0.2),
                lineHeight: CGFloat,
                circleRadius: CGFloat,
                draggingCircleRadius: CGFloat = 7) {
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
        self.bufferedColor = bufferedColor
        self.lineHeight = lineHeight
        self.circleRadius = circleRadius
        self.draggingCircleRadius = draggingCircleRadius
    }
}

// MARK: - Defaults

public extension KinescopePlayerTimelineConfiguration {
    
    static func builder() -> KinescopePlayerTimelineConfigurationBuilder {
        .init(configuration: .default)
    }

    static let `default`: KinescopePlayerTimelineConfiguration = {
        .init(activeColor: UIColor(red: 0.38, green: 0.38, blue: 0.988, alpha: 1),
              inactiveColor: UIColor(red: 1, green: 1, blue: 1, alpha: 0.32),
              bufferedColor: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2),
              lineHeight: 4,
              circleRadius: 0,
              draggingCircleRadius: 7)
    }()
    
}

// MARK: - Builder

public class KinescopePlayerTimelineConfigurationBuilder {
    private var activeColor: UIColor
    private var inactiveColor: UIColor
    private var bufferedColor: UIColor
    private var lineHeight: CGFloat
    private var circleRadius: CGFloat
    private var draggingCircleRadius: CGFloat
    
    public init(configuration: KinescopePlayerTimelineConfiguration = .default) {
        self.activeColor = configuration.activeColor
        self.inactiveColor = configuration.inactiveColor
        self.bufferedColor = configuration.bufferedColor
        self.lineHeight = configuration.lineHeight
        self.circleRadius = configuration.circleRadius
        self.draggingCircleRadius = configuration.draggingCircleRadius
    }
    
    public func setActiveColor(_ activeColor: UIColor) -> Self {
        self.activeColor = activeColor
        return self
    }
    
    public func setInactiveColor(_ inactiveColor: UIColor) -> Self {
        self.inactiveColor = inactiveColor
        return self
    }

    public func setBufferedColor(_ bufferedColor: UIColor) -> Self {
        self.bufferedColor = bufferedColor
        return self
    }
    
    public func setLineHeight(_ lineHeight: CGFloat) -> Self {
        self.lineHeight = lineHeight
        return self
    }
    
    public func setCircleRadius(_ circleRadius: CGFloat) -> Self {
        self.circleRadius = circleRadius
        return self
    }

    public func setDraggingCircleRadius(_ radius: CGFloat) -> Self {
        self.draggingCircleRadius = radius
        return self
    }
    
    public func build() -> KinescopePlayerTimelineConfiguration {
        .init(activeColor: activeColor,
              inactiveColor: inactiveColor,
              bufferedColor: bufferedColor,
              lineHeight: lineHeight,
              circleRadius: circleRadius,
              draggingCircleRadius: draggingCircleRadius)
    }
}
