//
//  KinescopePlayerOverlayConfiguration.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 30.03.2021.
//

import UIKit

/// Fast rewind(on double tap options)
public enum KinescopeFastRewind: Double {
    case five = 5.0
    case ten = 10.0
    case fifteen = 15.0

    var imageForward: UIImage {
        switch self {
        case .five:
            return UIImage.image(named: "FastRewind/5sec+")
        case .ten:
            return UIImage.image(named: "FastRewind/10sec+")
        case .fifteen:
            return UIImage.image(named: "FastRewind/15sec+")
        }
    }

    var imageBackward: UIImage {
        switch self {
        case .five:
            return UIImage.image(named: "FastRewind/5sec-")
        case .ten:
            return UIImage.image(named: "FastRewind/10sec-")
        case .fifteen:
            return UIImage.image(named: "FastRewind/15sec-")
        }
    }
}

/// Appearence preferences for overlay above video
public struct KinescopePlayerOverlayConfiguration {

    let playImage: UIImage
    let pauseImage: UIImage
    let replayImage: UIImage
    let fastForward: KinescopeFastRewind
    let fastBackward: KinescopeFastRewind
    let fastForwardImage: UIImage
    let fastBackwardImage: UIImage
    let backgroundColor: UIColor
    let duration: TimeInterval
    let nameConfiguration: KinescopeVideoNameConfiguration

    /// - parameter playImage: Image showing If video started after tapping on overlay
    /// - parameter pauseImage: Image showing If video paused after tapping on overlay
    /// - parameter replayImage: Image showing If video ended
    /// - parameter backgroundColor: Background color of overlay
    /// - parameter animationDuration: Duration of overlay appear animation in seconds
    /// - parameter fastForward: Time in seconds
    /// - parameter fastBackward: Time in seconds
    /// - parameter fastForwardImage: Optionl custom image
    /// - parameter fastBackwardImage: Optionl custom image
    /// - parameter duration: Overlay appearing time
    public init(playImage: UIImage,
                pauseImage: UIImage,
                replayImage: UIImage,
                fastForward: KinescopeFastRewind,
                fastBackward: KinescopeFastRewind,
                fastForwardImage: UIImage?,
                fastBackwardImage: UIImage?,
                backgroundColor: UIColor,
                duration: TimeInterval,
                nameConfiguration: KinescopeVideoNameConfiguration) {
        self.playImage = playImage
        self.pauseImage = pauseImage
        self.replayImage = replayImage
        self.fastForward = fastForward
        self.fastBackward = fastBackward
        self.fastForwardImage = fastForwardImage ?? fastForward.imageForward
        self.fastBackwardImage = fastBackwardImage ?? fastBackward.imageBackward
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
        replayImage: UIImage.image(named: "replay"),
        fastForward: .fifteen,
        fastBackward: .fifteen,
        fastForwardImage: nil,
        fastBackwardImage: nil,
        backgroundColor: UIColor.black.withAlphaComponent(0.3),
        duration: 5.0,
        nameConfiguration: .default
    )

}
