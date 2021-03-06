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
    let fastForwardImage: UIImage
    let fastBackwardImage: UIImage
    let backgroundColor: UIColor
    let duration: TimeInterval
    let nameConfiguration: KinescopeVideoNameConfiguration

    /// - parameter playImage: Image showing If video started after tapping on overlay
    /// - parameter pauseImage: Image showing If video paused after tapping on overlay
    /// - parameter backgroundColor: Background color of overlay
    /// - parameter animationDuration: Duration of overlay appear animation in seconds
    public init(playImage: UIImage,
                pauseImage: UIImage,
                fastForwardImage: UIImage,
                fastBackwardImage: UIImage,
                backgroundColor: UIColor,
                duration: TimeInterval,
                nameConfiguration: KinescopeVideoNameConfiguration) {
        self.playImage = playImage
        self.pauseImage = pauseImage
        self.fastForwardImage = fastForwardImage
        self.fastBackwardImage = fastBackwardImage
        self.backgroundColor = backgroundColor
        self.duration = duration
        self.nameConfiguration = nameConfiguration
    }
}

// MARK: - Defaults

public extension KinescopePlayerOverlayConfiguration {

    static let `default`: KinescopePlayerOverlayConfiguration = .init(
        playImage: UIImage.image(named: "play"),
        pauseImage: UIImage.image(named: "pause"),
        fastForwardImage: UIImage.image(named: "fastForward"),
        fastBackwardImage: UIImage.image(named: "fastBackward"),
        backgroundColor: UIColor.black.withAlphaComponent(0.3),
        duration: 5.0,
        nameConfiguration: .default
    )

}
