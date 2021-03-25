//
//  KinescopePlayerView.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//
// swiftlint:disable implicitly_unwrapped_optional

import UIKit
import AVFoundation

public class KinescopePlayerView: UIView {

    // MARK: - Private Properties

    /// View with AVPlayerLayer to fill size
    ///
    /// - Warning: should be internal or private
    public private(set) var playerView: PlayerView = {
        $0.layer.shouldRasterize = true
        $0.layer.rasterizationScale = UIScreen.main.scale
        $0.playerLayer.videoGravity = .resizeAspectFill
        return $0
    }(PlayerView())
    var playerControlView: PlayerControlView!

    // MARK: - Internal Properties

    ///
    public private(set) var previewView: UIImageView = UIImageView()

    // MARK: - Public Properties

    public var progressview: UIActivityIndicatorView!

    public var player: KinescopePlayer? {
        didSet {
            // Bind player with player view
            // KinescopePlayer should provide AVPlayer for playerView
        }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupInitialState()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupInitialState()
    }

    private func setupInitialState() {

        addSubview(playerView)
        stretch(view: playerView)

        addSubview(previewView)
        stretch(view: previewView)
        previewView.isHidden = true
    }

}
