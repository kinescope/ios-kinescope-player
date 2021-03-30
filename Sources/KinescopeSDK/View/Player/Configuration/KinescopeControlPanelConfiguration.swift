//
//  KinescopeControlPanelConfiguration.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 30.03.2021.
//

import UIKit

/// Appearence preferences for control panel with play/pause and other buttons
public struct KinescopeControlPanelConfiguration {

    let tintColor: UIColor
    let backgroundColor: UIColor
    let hideOnPlayTimeout: TimeInterval?

    /// - parameter tintColor: Tint Color of buttons and controls
    /// - parameter backgroundColor: Background color of panel
    /// - parameter hideOnPlayTimeout: Can hide control panel when video is playing some time.
    /// Require value in seconds. Do not use big values.
    /// Set `nil` to keep control panel always visible.
    public init(tintColor: UIColor, backgroundColor: UIColor, hideOnPlayTimeout: TimeInterval?) {
        self.tintColor = tintColor
        self.backgroundColor = backgroundColor
        self.hideOnPlayTimeout = hideOnPlayTimeout
    }
}
