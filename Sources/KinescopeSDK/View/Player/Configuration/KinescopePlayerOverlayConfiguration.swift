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
    let replayImage: UIImage
    let fastForwardImage: UIImage
    let fastBackwardImage: UIImage
    let backgroundColor: UIColor
    let duration: TimeInterval

    /// - parameter playImage: Image showing If video started after tapping on overlay
    /// - parameter pauseImage: Image showing If video paused after tapping on overlay
    /// - parameter replayImage: Image showing If video ended
    /// - parameter backgroundColor: Background color of overlay
    /// - parameter animationDuration: Duration of overlay appear animation in seconds
    public init(playImage: UIImage,
                pauseImage: UIImage,
                replayImage: UIImage,
                fastForwardImage: UIImage,
                fastBackwardImage: UIImage,
                backgroundColor: UIColor,
                duration: TimeInterval) {
        self.playImage = playImage
        self.pauseImage = pauseImage
        self.replayImage = replayImage
        self.fastForwardImage = fastForwardImage
        self.fastBackwardImage = fastBackwardImage
        self.backgroundColor = backgroundColor
        self.duration = duration
    }
}

// MARK: - Defaults

public extension KinescopePlayerOverlayConfiguration {

    static let `default`: KinescopePlayerOverlayConfiguration = .init(
        playImage: UIImage.image(named: "play"),
        pauseImage: UIImage.image(named: "pause"),
        replayImage: UIImage.image(named: "replay"),
        fastForwardImage: UIImage.image(named: "fastForward"),
        fastBackwardImage: UIImage.image(named: "fastBackward"),
        backgroundColor: UIColor.black.withAlphaComponent(0.3),
        duration: 5.0
    )

}
