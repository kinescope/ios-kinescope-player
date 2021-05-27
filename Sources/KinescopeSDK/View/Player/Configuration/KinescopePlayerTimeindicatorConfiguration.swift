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
    let leftPadding: CGFloat
    let rightPadding: CGFloat

    /// - parameter color: Color of label with time value
    /// - parameter fontSize: Font size of label with time value
    /// - parameter leftPadding: Padding from left side screen of device to time indicator
    /// - parameter rightPadding: Padding from time indicator right anchor to timeline view
    public init(color: UIColor,
                fontSize: CGFloat,
                leftPadding: CGFloat,
                rightPadding: CGFloat) {
        self.color = color
        self.fontSize = fontSize
        self.leftPadding = leftPadding
        self.rightPadding = rightPadding
    }
}

// MARK: - Defaults

public extension KinescopePlayerTimeindicatorConfiguration {

    static let `default`: KinescopePlayerTimeindicatorConfiguration = .init(color: .white,
                                                                            fontSize: 14,
                                                                            leftPadding: 16,
                                                                            rightPadding: 8)

}
