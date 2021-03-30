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
    let animationDuration: TimeInterval?

    /// - parameter playImage: Image showing If video started after tapping on overlay
    /// - parameter pauseImage: Image showing If video paused after tapping on overlay
    /// - parameter animationDuration: Duration of image appear animation in seconds
    public init(playImage: UIImage, pauseImage: UIImage, animationDuration: TimeInterval) {
        self.playImage = playImage
        self.pauseImage = pauseImage
        self.animationDuration = animationDuration
    }
}
