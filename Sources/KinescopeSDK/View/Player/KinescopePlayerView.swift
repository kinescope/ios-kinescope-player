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

    // FIXME: Add localization
    private var selectedQuality = NSAttributedString(string: "Auto")

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

    func set(options: [KinescopePlayerOption]) {
        controlPanel?.set(options: options)
    }

    func change(quality: String, manualQuality: Bool) {
        // FIXME: Add localization
        if manualQuality {
            set(quality: quality)
        } else {
            set(quality: "Auto " + quality)
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

    func handleDisclosureActions(for title: String) {
        let model: SideMenu.Model
        // FIXME: Add configs for subtitle and playback speed
        switch SideMenu.Settings(rawValue: title) {
        case .playbackSpeed:
            model = .init(title: title, isRoot: false, isDownloadable: false, items: [])
        case .subtitles:
            model = .init(title: title, isRoot: false, isDownloadable: false, items: [])
        case .quality:
            model = makeQualitySideMenuModel(with: title)
        case .none:
            model = .init(title: title, isRoot: false, isDownloadable: false, items: [])
        }

        presentSideMenu(model: model)
    }

    func handleDescriptionActions(for sideMenu: SideMenu, index: Int) {
        switch SideMenu.DescriptionTitle(rawValue: sideMenu.title) {
        case .attachments:
            delegate?.didSelectAttachment(with: index)
            sideMenuWillBeDismissed(sideMenu, withRoot: true)
        case .download:
            delegate?.didSelectAsset(with: index)
            sideMenuWillBeDismissed(sideMenu, withRoot: true)
        case .none:
            return
        }

    }

    func makeQualitySideMenuModel(with title: String) -> SideMenu.Model {
        let qualities = delegate?.didShowQuality() ?? []
        var items = qualities.compactMap { quality -> SideMenu.Item in
            let selected = self.selectedQuality.string.trimmingCharacters(in: .symbols) == quality
            return .checkmark(title: .init(string: quality), selected: selected)
        }

        // FIXME: Add localization
        let autoTitle = NSAttributedString(string: "Auto")
        let selected = selectedQuality.string.hasPrefix(autoTitle.string)
        items.insert(.checkmark(title: autoTitle, selected: selected), at: 0)
        return .init(title: title, isRoot: false, isDownloadable: false, items: items)
    }

    func makeAttachmentSideMenuItems() -> [SideMenu.Item] {
        guard let materials = delegate?.didShowAttachments() else {
            return []
        }

        var items: [SideMenu.Item] = []
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useAll]
        bcf.countStyle = .file

        // FIXME: Add localization
        for (index, material) in materials.enumerated() {
            let title = String(index + 1) + ". " + material.title
            let value = bcf.string(fromByteCount: Int64(material.size))
            items.append(.description(title: title, value: value))
        }

        return items
    }

    func makeAssetsSideMenuItems() -> [SideMenu.Item] {
        guard let materials = delegate?.didShowAssets() else {
            return []
        }

        var items: [SideMenu.Item] = []
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useAll]
        bcf.countStyle = .file

        // FIXME: Add localization
        for material in materials {
            var title = material.quality
            let value = bcf.string(fromByteCount: Int64(material.fileSize))
            items.append(.description(title: title, value: value))
        }

        return items
    }

    func handleCheckmarkActions(for title: NSAttributedString, sideMenu: SideMenu) {
        // FIXME: Add configs for another logic
        handleQualityCheckmarkAction(for: title, sideMenu: sideMenu)
    }

    func handleQualityCheckmarkAction(for title: NSAttributedString, sideMenu: SideMenu) {
        delegate?.didSelect(quality: title.string)
        sideMenuWillBeDismissed(sideMenu, withRoot: true)
        set(quality: title.string)
    }

    func set(quality: String) {
        let color = config.sideMenu.item.valueColor
        let font = config.sideMenu.item.valueFont
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        selectedQuality = quality.attributedStringWithAssetIconIfNeeded(attributes: attributes)
    }

    func presentSideMenu(model: SideMenu.Model) {
        let sideMenu = SideMenu(config: config.sideMenu, model: model)
        sideMenu.delegate = self
        sideMenuCoordinator.present(view: sideMenu, in: self, animated: true)
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
            delegate?.didPresentFullscreen(from: self)
        case .settings:
            // FIXME: Add localization
            let model = SideMenu.Model(title: SideMenu.Settings.title,
                                       isRoot: true,
                                       isDownloadable: false,
                                       items: [
                                        .disclosure(title: SideMenu.Settings.playbackSpeed.rawValue,
                                                    value: nil),
                                        .disclosure(title: SideMenu.Settings.subtitles.rawValue,
                                                    value: nil),
                                        .disclosure(title: SideMenu.Settings.quality.rawValue,
                                                    value: selectedQuality)
                                       ])
            presentSideMenu(model: model)
        case .download:
            let items = makeAssetsSideMenuItems()
            let model = SideMenu.Model(title: SideMenu.DescriptionTitle.download.rawValue,
                                       isRoot: true,
                                       isDownloadable: true,
                                       items: items)
            presentSideMenu(model: model)
        case .attachments:
            let items = makeAttachmentSideMenuItems()
            let model = SideMenu.Model(title: SideMenu.DescriptionTitle.attachments.rawValue,
                                       isRoot: true,
                                       isDownloadable: true,
                                       items: items)
            presentSideMenu(model: model)
        case .airPlay:
            break
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

    func sideMenuDidSelect(item: SideMenu.Item, rowIndex: Int, sideMenu: SideMenu) {
        switch item {
        case .disclosure(let title, _):
            handleDisclosureActions(for: title)
        case .checkmark(let title, _):
            handleCheckmarkActions(for: title, sideMenu: sideMenu)
        case .description:
            handleDescriptionActions(for: sideMenu, index: rowIndex)
        }
    }

    func downloadAllTapped(for title: String) {
        delegate?.didSelectDownloadAll(for: title)
    }

}
