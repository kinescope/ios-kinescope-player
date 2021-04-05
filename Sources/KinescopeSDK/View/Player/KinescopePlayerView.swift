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
    private(set) var playerView: PlayerView!
    private(set) weak var controlPanel: PlayerControlView?
    private(set) weak var overlay: PlayerOverlayView?
    private(set) var progressView: KinescopeActivityIndicator!

    private var config: KinescopePlayerViewConfiguration!

    /// One coordination for phones and other for pads
    private let sideMenuCoordinator = SideMenuSlideCoordinator()

    // MARK: - Internal Properties

    weak var delegate: KinescopePlayerViewDelegate?
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

    func change(status: AVPlayer.Status) {
        switch status {
        case .readyToPlay:
            overlay?.isHidden = false
            progressView.showVideoProgress(isLoading: false)
            previewView.isHidden = true
        case .failed, .unknown:
            // FIXME: Error handling
            break
        @unknown default:
            break
        }
    }

    func change(timeControlStatus: AVPlayer.TimeControlStatus) {
        switch timeControlStatus {
        case .playing:
            overlay?.isHidden = false
            overlay?.set(playing: true)
        case .paused, .waitingToPlayAtSpecifiedRate:
            overlay?.set(playing: false)
        @unknown default:
            break
        }
    }
}

// MARK: - Public

public extension KinescopePlayerView {

    /// Set Layout and Appearance Configuration
    ///
    /// - parameter config: Configuration of player
    func setLayout(with config: KinescopePlayerViewConfiguration) {

        self.config = config

        clearSubviews()

        configurePlayerView(with: config.gravity)
        configurePreviewView()

        if let overlay = config.overlay {
            configureOverlay(with: overlay)
        }

        if let controlPanel = config.controlPanel {
            configureControlPanel(with: controlPanel)
        }

        configureProgressView(with: config.activityIndicator)
    }

}

// MARK: - Private

private extension KinescopePlayerView {

    func clearSubviews() {
        subviews.forEach {
            $0.removeFromSuperview()
        }
    }

    func configurePlayerView(with gravity: AVLayerVideoGravity) {
        let playerView = PlayerView()
        playerView.layer.shouldRasterize = true
        playerView.layer.rasterizationScale = UIScreen.main.scale
        playerView.playerLayer.videoGravity = gravity
        addSubview(playerView)
        stretch(view: playerView)

        self.playerView = playerView
    }

    func configurePreviewView() {
        addSubview(previewView)
        stretch(view: previewView)
    }

    func configureProgressView(with progressView: KinescopeActivityIndicator) {
        addSubview(progressView)
        centerChild(view: progressView)

        self.progressView = progressView
    }

    func configureControlPanel(with config: KinescopeControlPanelConfiguration) {
        let controlPanel = PlayerControlView(config: config)
        addSubview(controlPanel)
        bottomChild(view: controlPanel)

        controlPanel.set(options: [.settings, .fullscreen, .more])

        self.controlPanel = controlPanel
        controlPanel.output = self
    }

    func configureOverlay(with config: KinescopePlayerOverlayConfiguration) {
        let overlay = PlayerOverlayView(config: config, delegate: self)
        overlay.isHidden = true
        addSubview(overlay)
        stretch(view: overlay)

        self.overlay = overlay
    }

}

// MARK: - PlayerOverlayViewDelegate

extension KinescopePlayerView: PlayerOverlayViewDelegate {
    func didPlay(videoEnded: Bool) {
        delegate?.didPlay(videoEnded: videoEnded)
    }

    func didPause() {
        delegate?.didPause()
    }

    func didFastForward() {
        delegate?.didFastForward()
    }

    func didFastBackward() {
        delegate?.didFastBackward()
    }
}

// MARK: - PlayerControlOutput

extension KinescopePlayerView: PlayerControlOutput {
    func didSelect(option: KinescopePlayerOption) {
        switch option {
        case .fullscreen:
            delegate?.presentFullscreen(from: self)
        case .settings:
            // Add localisation?
            let model = SideMenu.Model(title: "Settings",
                                       isRoot: true,
                                       items: [
                                         .disclosure(title: "Playback speed", value: nil),
                                         .disclosure(title: "Subtitles", value: nil),
                                         .disclosure(title: "Quality", value: .init(string: "Auto"))
                                       ])
            let sideMenu = SideMenu(config: config.sideMenu, model: model)
            sideMenu.delegate = self
            sideMenuCoordinator.present(view: sideMenu, in: self, animated: true)
        default:
            break
        }
    }

    func onTimelinePositionChanged(to position: CGFloat) {
        delegate?.didSeek(to: Double(position))
    }

}

// MARK: - SideMenuDelegate

extension KinescopePlayerView: SideMenuDelegate {

    func sideMenuWillBeDismissed(_ sideMenu: SideMenu, withRoot: Bool) {

        if withRoot {
            let sideMenus = subviews.compactMap { $0 as? SideMenu }
            sideMenus.forEach { [weak self] sideMenu in
                guard let parentView = self else {
                    return
                }
                self?.sideMenuCoordinator.dismiss(view: sideMenu, from: parentView, animated: true)
            }
        } else {
            sideMenuCoordinator.dismiss(view: sideMenu, from: self, animated: true)
        }
    }

    func sideMenuDidSelect(item: SideMenu.Item) {
        switch item {
        case .disclosure(let title, _):
            let model = SideMenu.Model(title: title,
                                       isRoot: false,
                                       items: [])
            let sideMenu = SideMenu(config: config.sideMenu, model: model)
            sideMenu.delegate = self
            sideMenuCoordinator.present(view: sideMenu, in: self, animated: true)
        }
    }

}
