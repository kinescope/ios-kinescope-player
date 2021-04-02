//
//  KinescopePlayerOverlayConfiguration.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 30.03.2021.
//

import UIKit

/// Appearence preferences for overlay above video
public struct KinescopePlayerOverlayConfiguration {

    let playImage: UIImage
    let pauseImage: UIImage
    let backgroundColor: UIColor
    let animationDuration: TimeInterval
    let nameConfiguration: KinescopeVideoNameConfiguration

    /// - parameter playImage: Image showing If video started after tapping on overlay
    /// - parameter pauseImage: Image showing If video paused after tapping on overlay
    /// - parameter backgroundColor: Background color of overlay
    /// - parameter animationDuration: Duration of image appear animation in seconds
    public init(playImage: UIImage,
                pauseImage: UIImage,
                backgroundColor: UIColor,
                animationDuration: TimeInterval,
                nameConfiguration: KinescopeVideoNameConfiguration) {
        self.playImage = playImage
        self.pauseImage = pauseImage
        self.backgroundColor = backgroundColor
        self.animationDuration = animationDuration
        self.nameConfiguration = nameConfiguration
    }
}

// MARK: - Defaults

public extension KinescopePlayerOverlayConfiguration {

    static let `default`: KinescopePlayerOverlayConfiguration = .init(
        playImage: UIImage.image(named: "play"),
        pauseImage: UIImage.image(named: "pause"),
        backgroundColor: UIColor.black.withAlphaComponent(0.3),
        animationDuration: 5.0,
        nameConfiguration: .default
    )

}
