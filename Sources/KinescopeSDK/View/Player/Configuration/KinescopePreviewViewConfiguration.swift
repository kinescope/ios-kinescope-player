//
//  KinescopePreviewViewConfiguration.swift
//  KinescopeSDK
//
//  Created by Никита Гагаринов on 28.04.2021.
//

import Foundation

/// Appearence preferences for preview view
public struct KinescopePreviewViewConfiguration {

    let playImage: UIImage
    let durationFont: UIFont
    let durationColor: UIColor
    let nameConfiguration: KinescopeVideoNameConfiguration

    /// - parameter playImage: Image showing If video started after tapping on overlay
    /// - parameter durationFont: Font of duration video label
    /// - parameter durationColor: Text color of  duration video label
    /// - parameter nameConfiguration: Configuration of video title and description lables
    public init(playImage: UIImage,
                durationFont: UIFont,
                durationColor: UIColor,
                nameConfiguration: KinescopeVideoNameConfiguration) {
        self.playImage = playImage
        self.durationFont = durationFont
        self.durationColor = durationColor
        self.nameConfiguration = nameConfiguration
    }
}

// MARK: - Defaults

public extension KinescopePreviewViewConfiguration {

    static let `default`: KinescopePreviewViewConfiguration = .init(
        playImage: UIImage.image(named: "play"),
        durationFont: .systemFont(ofSize: 14, weight: .regular),
        durationColor: .white,
        nameConfiguration: .default
    )

}
