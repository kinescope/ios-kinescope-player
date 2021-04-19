//
//  KinescopePlayerShadowOverlayConfiguration.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 16.04.2021.
//

import UIKit

/// Appearance of shadow overlay beneath menu
public struct KinescopePlayerShadowOverlayConfiguration {

    let color: UIColor

    /// - parameter color: Color of shadow overlay
    public init(color: UIColor) {
        self.color = color
    }

}

// MARK: - Defaults

public extension KinescopePlayerShadowOverlayConfiguration {

    static let `default`: Self = .init(color: UIColor(red: 0.133,
                                                      green: 0.133,
                                                      blue: 0.133,
                                                      alpha: 0.32))

}
