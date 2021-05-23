//
//  PlayerView.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//

import UIKit
import AVFoundation

/// View with AVPlayerLayer layerClass
class PlayerView: UIView {

    // MARK: - Private Properties

    var player: AVPlayer? {
        get {
            playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }

    var playerLayer: AVPlayerLayer {
        // swiftlint:disable:next force_cast
        return layer as! AVPlayerLayer
    }

    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}
