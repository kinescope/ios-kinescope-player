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
    private var playerView: PlayerView!
    private var controlPanel: PlayerControlView?
    private var overlay: PlayerOverlayView?

    // MARK: - Internal Properties

    var progressView: KinescopeActivityIndicator!
    public private(set) var previewView: UIImageView = UIImageView()

    // MARK: - Public Properties

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout(with: .default)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setLayout(with: .default)
    }

    // MARK: - Internal Methods

    func startLoader() {
        previewView.isHidden = false
        progressView.showVideoProgress(isLoading: true)
    }

    func stopLoader() {
        progressView.showVideoProgress(isLoading: false)
        previewView.isHidden = true
    }

}

// MARK: - Public

public extension KinescopePlayerView {

    func setLayout(with config: KinescopePlayerViewConfiguration) {

        clearSubviews()

        configurePlayerView(with: config.gravity)
        configurePreviewView()
        configureProgressView()
    }

}

// MARK: - Private

private extension KinescopePlayerView {

    func clearSubviews() {
        subviews.forEach {
            $0.removeFromSuperview()
        }
    }

    private func configurePlayerView(with gravity: AVLayerVideoGravity) {
        let playerView = PlayerView()
        playerView.layer.shouldRasterize = true
        playerView.layer.rasterizationScale = UIScreen.main.scale
        playerView.playerLayer.videoGravity = gravity
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
