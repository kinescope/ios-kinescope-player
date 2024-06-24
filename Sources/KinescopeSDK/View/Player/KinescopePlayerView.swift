//
//  KinescopePlayerView.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//
// swiftlint:disable implicitly_unwrapped_optional

import UIKit
import AVFoundation
import AVKit

public class KinescopePlayerView: UIView {

    // MARK: - Private Properties

    /// View with AVPlayerLayer to fill size
    private(set) var playerView: PlayerView!
    private(set) weak var controlPanel: PlayerControlView?
    private(set) weak var overlay: PlayerOverlayView?
    private(set) weak var errorOverlay: ErrorView?
    private(set) weak var announceSnack: AnnounceView?
    private(set) var progressView: KinescopeActivityIndicator!
    private(set) var shadowOverlay: PlayerShadowOverlayView?
    private(set) var pipController: AVPictureInPictureController?

    private(set) var config: KinescopePlayerViewConfiguration!

    /// One coordination for phones and other for pads
    private let sideMenuCoordinator = SideMenuSlideCoordinator()

    private var playingRateProvider: SideMenuItemsProvider?
    private var qualityProvider: SideMenuItemsProvider?
    private var subtitlesProvider: SideMenuItemsProvider?

    private lazy var overlayDebouncer = Debouncer(timeInterval: overlay?.duration ?? 0.0)

    // MARK: - Internal Properties

    weak var delegate: KinescopePlayerViewDelegate?
    var canBeFullScreen: Bool {
        return controlPanel?.optionsMenu.options.contains(.fullscreen) ?? false
    }

    // MARK: - Public Properties

    public private(set) var previewView: UIImageView = UIImageView()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout(with: .default)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setLayout(with: .default)
    }

    deinit {
        // Workaround to prevent plaing audio when player deinited(due to enabled background mode)
        if !(pipController?.isPictureInPictureActive ?? false) {
            playerView.player?.pause()
        }
    }

    // MARK: - Internal Methods

    func startLoader() {
        overlay?.isHidden = true
        previewView.isHidden = false
        progressView.showVideoProgress(isLoading: true)
    }

    func stopLoader(withPreview: Bool = true) {
        progressView.showVideoProgress(isLoading: false)
        previewView.isHidden = withPreview
        overlay?.isHidden = false
    }

    func change(timeControlStatus: AVPlayer.TimeControlStatus) {
        switch timeControlStatus {
        case .playing:
            controlPanel?.isHidden = false
            overlay?.isHidden = false
            overlay?.set(playing: true)
            progressView.showVideoProgress(isLoading: false)
        case .paused:
            overlay?.set(playing: false)
        case .waitingToPlayAtSpecifiedRate:
            overlay?.set(playing: false)
            progressView.showVideoProgress(isLoading: true)
        @unknown default:
            break
        }
    }

    func set(options: [KinescopePlayerOption]) {
        controlPanel?.set(options: options)
    }
    
    func bind(playingRateProvider: SideMenuItemsProvider,
              videoQualityProvider: SideMenuItemsProvider,
              subtitlesProvider: SubtitlesProvider) {
        self.playingRateProvider = playingRateProvider
        self.qualityProvider = videoQualityProvider
        self.subtitlesProvider = subtitlesProvider
    }

    func set(preview: String?) {
        if let preview, let previewService = config.previewService {
            previewService.fetchPreview(for: preview, into: previewView)
        } else {
            previewView.image = nil
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
        configureAnnounce(with: config.announceSnack)

        if let overlay = config.overlay {
            configureOverlay(with: overlay)
        }

        if let controlPanel = config.controlPanel {
            configureControlPanel(with: controlPanel)
        }

        if let shadowOverlay = config.shadowOverlay {
            configureShadowOverlay(with: shadowOverlay)
        }

        if let errorOverlay = config.errorOverlay {
            configureError(with: errorOverlay)
        }

        configureProgressView(with: config.activityIndicator)
        configurePip()
    }

    /// Show/hide player view overlay
    /// - Parameter shown: if true - show, hide otherwise
    func showOverlay(_ shown: Bool) {
        didTap(isSelected: !shown)
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

    func configurePip() {
        pipController = AVPictureInPictureController(playerLayer: playerView.playerLayer)
    }

    func configureControlPanel(with config: KinescopeControlPanelConfiguration) {
        let controlPanel = PlayerControlView(config: config)
        addSubview(controlPanel)
        bottomChildWithSafeArea(view: controlPanel)
        controlPanel.isHidden = true

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

    func configureError(with config: KinescopeErrorConfiguration) {
        let overlay = ErrorView(config: config, delegate: self)
        overlay.isHidden = true
        addSubview(overlay)
        stretch(view: overlay)

        self.errorOverlay = overlay
    }

    func configureAnnounce(with config: KinescopeAnnounceConfiguration) {
        let snack = AnnounceView(config: config)
        snack.isHidden = true
        addSubview(snack)
        bottomLeftChildWithSafeArea(view: snack, with: 16)

        self.announceSnack = snack
    }

    func configureShadowOverlay(with config: KinescopePlayerShadowOverlayConfiguration) {
        let overlay = PlayerShadowOverlayView(config: config, delegate: self)
        overlay.isHidden = true
        addSubview(overlay)
        stretch(view: overlay)

        self.shadowOverlay = overlay
    }

    func handleDisclosureActions(for title: String) {
        let model: SideMenu.Model?
        switch SideMenu.Settings.getType(by: title) {
        case .playbackSpeed:
            model = makeSpeedSideMenuModel(with: title)
        case .subtitles:
            model = makeSubtitlesSideMenuModel(with: title, root: false)
        case .quality:
            model = makeQualitySideMenuModel(with: title)
        case .none:
            model = nil
        }
        
        guard let model else {
            return
        }

        presentSideMenu(model: model)
    }

    func handleDescriptionActions(for sideMenu: SideMenu, id: String) {
        switch SideMenu.DescriptionTitle.getType(by: sideMenu.title) {
        case .attachments:
            delegate?.didSelectAttachment(with: id)
            sideMenuWillBeDismissed(sideMenu, withRoot: true)
        case .download:
            delegate?.didSelect(quality: id)
            sideMenuWillBeDismissed(sideMenu, withRoot: true)
        case .none:
            return
        }

    }

    func makeSpeedSideMenuModel(with title: String) -> SideMenu.Model {
        .init(title: title,
              isRoot: false,
              isDownloadable: false,
              items: playingRateProvider?.items ?? [])
    }

    func makeQualitySideMenuModel(with title: String) -> SideMenu.Model {
        .init(title: title,
              isRoot: false,
              isDownloadable: false,
              items: qualityProvider?.items ?? [])
    }

    func makeSubtitlesSideMenuModel(with title: String, root: Bool) -> SideMenu.Model {
        .init(title: title,
              isRoot: root,
              isDownloadable: false,
              items: subtitlesProvider?.items ?? [])
    }

    func makeAttachmentSideMenuItems() -> [SideMenu.Item] {
        guard let materials = delegate?.didShowAttachments() else {
            return []
        }

        var items: [SideMenu.Item] = []
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useAll]
        bcf.countStyle = .file

        for (index, material) in materials.enumerated() {
            let title = String(index + 1) + ". " + material.title
            let value = bcf.string(fromByteCount: Int64(material.size))
            items.append(.description(id: material.id,
                                      title: title,
                                      value: value))
        }

        return items
    }

    func makeAssetsSideMenuItems() -> [SideMenu.Item] {
//        guard let materials = delegate?.didShowAssets() else {
//            return []
//        }
//
//        var items: [SideMenu.Item] = []
//        let bcf = ByteCountFormatter()
//        bcf.allowedUnits = [.useAll]
//        bcf.countStyle = .file
//
//        for material in materials {
//            let title = material.label
//            let value = material.name
//            // TODO: - Feature.assetDownloader: how to get fileSize ?
////            let value = bcf.string(fromByteCount: Int64(material.fileSize))
//            items.append(.description(id: title, 
//                                      title: title,
//                                      value: value))
//        }
//
//        return items
        return []
    }

    func handleCheckmarkActions(for title: NSAttributedString, sideMenu: SideMenu) {
        switch SideMenu.Settings.getType(by: sideMenu.title) {
        case .quality:
            delegate?.didSelect(quality: title.string)
        case .subtitles:
            delegate?.didSelect(subtitles: title.string)
        case .playbackSpeed:
            delegate?.didSelect(rate: KinescopePlayingRate.from(string: title.string).rawValue)
        case .none:
            break
        }
        sideMenuWillBeDismissed(sideMenu, withRoot: true)
    }
    
    func formatValue(_ value: String?) -> NSAttributedString {
        guard let value else {
            return NSAttributedString()
        }
        let color = config.sideMenu.item.valueColor
        let font = config.sideMenu.item.valueFont
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        return value.attributedStringWithAssetIconIfNeeded(attributes: attributes)
    }

    func presentSideMenu(model: SideMenu.Model) {
        let sideMenu = SideMenu(config: config.sideMenu, model: model)
        sideMenu.delegate = self
        sideMenuCoordinator.present(view: sideMenu, in: self, animated: true)
        showOverlay(false)
        showShadow()
    }

    func showShadow() {
        guard let shadowOverlay = shadowOverlay else {
            return
        }
        shadowOverlay.showAnimated()
    }

    func hideShadow() {
        guard let shadowOverlay = shadowOverlay else {
            return
        }
        shadowOverlay.hideAnimated(with: { shadowOverlay.isHidden = false })
    }

    func addDebouncerHandler() {
        overlayDebouncer.handler = { [weak self] in
            guard let self else {
                return
            }
            self.overlay?.isSelected = false
            self.controlPanel?.hideAnimated(with: { self.controlPanel?.expanded = false })
        }
    }

}

// MARK: - PlayerOverlayViewDelegate

extension KinescopePlayerView: PlayerOverlayViewDelegate {

    func didTap(isSelected: Bool) {
        if isSelected {
            if !(controlPanel?.expanded ?? true) {
                overlay?.isSelected = false
                controlPanel?.hideAnimated()
            } else {
                controlPanel?.expanded = false
            }
        } else {
            overlay?.isSelected = true
            controlPanel?.showAnimated()
            addDebouncerHandler()
        }
        overlayDebouncer.renewInterval()
    }

    func didPlay() {
        addDebouncerHandler()
        overlayDebouncer.renewInterval()
        delegate?.didPlay()
    }

    func didPause() {
        overlayDebouncer.handler = { }
        delegate?.didPause()
    }

    func didFastForward() {
        overlayDebouncer.renewInterval()
        delegate?.didFastForward()
    }

    func didFastBackward() {
        overlayDebouncer.renewInterval()
        delegate?.didFastBackward()
    }
}

// MARK: - ErrorViewOutput

extension KinescopePlayerView: ErrorViewOutput {
    func didRerty() {
        didPlay()
    }
}

// MARK: - PlayerControlOutput

extension KinescopePlayerView: PlayerControlOutput {
    func didSelect(option: KinescopePlayerOption) {
        overlayDebouncer.renewInterval()
        switch option {
        case .fullscreen:
            overlayDebouncer.handler = { }
            delegate?.didPresentFullscreen(from: self)
        case .settings:
            let model = SideMenu.Model(title: L10n.Player.settings,
                                       isRoot: true,
                                       isDownloadable: false,
                                       items: [
                                        .disclosure(title: L10n.Player.playbackSpeed,
                                                    value: formatValue(playingRateProvider?.selectedTitle)),
                                        .disclosure(title: L10n.Player.subtitles,
                                                    value: formatValue(subtitlesProvider?.selectedTitle)),
                                        .disclosure(title: L10n.Player.videoQuality,
                                                    value: formatValue(qualityProvider?.selectedTitle))
                                       ])
            presentSideMenu(model: model)
        case .download:
            let items = makeAssetsSideMenuItems()
            let model = SideMenu.Model(title: L10n.Player.download,
                                       isRoot: true,
                                       isDownloadable: true,
                                       items: items)
            presentSideMenu(model: model)
        case .attachments:
            let items = makeAttachmentSideMenuItems()
            let model = SideMenu.Model(title: L10n.Player.attachments,
                                       isRoot: true,
                                       isDownloadable: true,
                                       items: items)
            presentSideMenu(model: model)
        case .airPlay:
            break
        case .subtitles:
            let model = makeSubtitlesSideMenuModel(with: L10n.Player.subtitles,
                                                   root: true)
            presentSideMenu(model: model)
        case .pip:
            let isPipActive = pipController?.isPictureInPictureActive ?? false
            isPipActive ? pipController?.stopPictureInPicture() : pipController?.startPictureInPicture()
        case .custom(let id, _):
            delegate?.didSelect(option: id, optionView: controlPanel?.getCustomOptionView(by: id) ?? self)
        default:
            break
        }
    }

    func onTimelinePositionChanged(to position: CGFloat) {
        delegate?.didSeek(to: Double(position))
        overlayDebouncer.renewInterval()
    }

    func onUpdate() {
        delegate?.didConfirmSeek()
        overlayDebouncer.renewInterval()
    }

}

// MARK: - SideMenuDelegate

extension KinescopePlayerView: SideMenuDelegate {

    func sideMenuWillBeDismissed(_ sideMenu: SideMenu, withRoot: Bool) {
        if withRoot {
            hideShadow()
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
        case .description(let id, _, _):
            handleDescriptionActions(for: sideMenu, id: id)
        }
    }

    func downloadAllTapped(for title: String) {
        delegate?.didSelectDownloadAll(for: title)
    }

}

// MARK: - ShadowOverlayOutput

extension KinescopePlayerView: ShadowOverlayDelegate {

    func onTap() {
        if let sideMenu = subviews.compactMap({ $0 as? SideMenu }).first {
            sideMenuWillBeDismissed(sideMenu, withRoot: true)
        }
    }

}

