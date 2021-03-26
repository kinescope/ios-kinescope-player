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
    var playerView: PlayerView!
    var playerControlView: PlayerControlView!

    // MARK: - Internal Properties

    ///
    public private(set) var previewView: UIImageView = UIImageView()

    // MARK: - Public Properties

    public var progressView: UIActivityIndicatorView!

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupInitialState()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupInitialState()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        progressView.center = playerView.center
    }

    // MARK: - Public Methods

    public func set(videoGravity: AVLayerVideoGravity) {
        playerView.playerLayer.videoGravity = videoGravity
    }

    // MARK: - Internal Methods

    func startLoader() {
        progressView.isHidden = false
        progressView.startAnimating()
    }

    func stopLoader() {
        progressView.stopAnimating()
    }

    // MARK: - Private Methods

    private func setupInitialState() {
        configurePlayerView()
        configurePreviewView()
        configureProgressView()
    }

    private func configurePlayerView() {
        let playerView = PlayerView()
        playerView.layer.shouldRasterize = true
        playerView.layer.rasterizationScale = UIScreen.main.scale
        addSubview(playerView)
        stretch(view: playerView)
        self.playerView = playerView
    }

    private func configurePreviewView() {
        addSubview(previewView)
        stretch(view: previewView)
    }

    private func configureProgressView() {
        let progressView = UIActivityIndicatorView(style: .whiteLarge)
        progressView.hidesWhenStopped = true
        addSubview(progressView)
        self.progressView = progressView
    }
}
