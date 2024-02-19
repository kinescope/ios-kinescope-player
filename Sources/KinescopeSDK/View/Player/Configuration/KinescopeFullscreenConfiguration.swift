//
//  KinescopeFullscreenConfiguration.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 02.04.2021.
//

import UIKit

/// Appearence preferences for title and subtitle above video
public struct KinescopeFullscreenConfiguration {

    let orientation: UIInterfaceOrientation
    let orientationMask: UIInterfaceOrientationMask
    let backgroundColor: UIColor

    /// - Parameters:
    ///   - orientation: Preferred orientation of fullscreenController
    ///   - orientationMask: Supported orientations mask for fullscreenController
    ///   - backgroundColor: Color for background
    public init(orientation: UIInterfaceOrientation, orientationMask: UIInterfaceOrientationMask, backgroundColor: UIColor) {
        self.orientation = orientation
        self.orientationMask = orientationMask
        self.backgroundColor = backgroundColor
    }
}

// MARK: - Defaults

public extension KinescopeFullscreenConfiguration {

    static func preferred(for video: KinescopeVideo?) -> KinescopeFullscreenConfiguration {
        guard let asset = video?.qualityMap?.first else {
            return landscape
        }
        
        // TODO: - resolve issue with landscape/portrait resolution

//        let resolution = asset.resolution.split(whereSeparator: { !$0.isHexDigit }).compactMap { Int($0) }
//
//        guard let width = resolution.first, let height = resolution.last else {
//            return landscape
//        }
//
//        return width > height ? .landscape : .portrait
        return .landscape
    }

    static let landscape: KinescopeFullscreenConfiguration = .init(
        orientation: .landscapeRight,
        orientationMask: .landscape,
        backgroundColor: .black)

    static let portrait: KinescopeFullscreenConfiguration = .init(
        orientation: .portrait,
        orientationMask: .portrait,
        backgroundColor: .black)
}
