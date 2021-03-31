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
    let font: UIFont

    /// - parameter color: Color of label with time value
    /// - parameter font: Font of label with time value
    public init(color: UIColor,
                font: UIFont) {
        self.color = color
        self.font = font
    }
}
