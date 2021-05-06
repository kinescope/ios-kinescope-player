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
    private(set) var progressView: KinescopeActivityIndicator!
    private(set) var shadowOverlay: PlayerShadowOverlayView?
    private(set) var pipController: AVPictureInPictureController?
    private var errorView: ErrorView?
    private var nameView: VideoNameView?
    private var nameDisplayingType: KinescopeVideoNameDisplayingType = .hidesWithOverlay

    private var config: KinescopePlayerViewConfiguration!

    /// One coordination for phones and other for pads
    private let sideMenuCoordinator = SideMenuSlideCoordinator()

    private var selectedQuality = NSAttributedString(string: L10n.Player.auto)
    private var selectedSubtitles = NSAttributedString(string: L10n.Player.off)
    private lazy var overlayDebouncer = Debouncer(timeInterval: overlay?.duration ?? 0.0)
    private lazy var timelineDebouncer = Debouncer(timeInterval: 1)
    private var playPauseReplayState: PlayPauseReplayState = .play {
        didSet {
            overlay?.playPauseReplayState = playPauseReplayState
        }
    }

    // MARK: - Internal Properties

    weak var delegate: KinescopePlayerViewDelegate?
    var canBeFullScreen: Bool {
        return controlPanel?.optionsMenu.options.contains(.fullscreen) ?? false
    }
    var state: PlayerViewState = .loading {
        didSet {
            updateViewState()
        }
    }

    // MARK: - Public Properties

    public private(set) var previewImage: UIImageView = UIImageView()

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

    func set(options: [KinescopePlayerOption]) {
        controlPanel?.set(options: options)
    }

    func change(quality: String, manualQuality: Bool) {
        if manualQuality {
            set(quality: quality)
        } else {
            set(quality: L10n.Player.auto + " " + quality)
        }
    }

    func set(title: String, subtitle: String) {
        nameView?.set(title: title, subtitle: subtitle)
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
        configurePreviewImage()
        configureErrorView(with: config.errorState)
        configureNameView(with: config)

        if let overlay = config.overlay {
            configureOverlay(with: overlay)
        }

        if let controlPanel = config.controlPanel {
            configureControlPanel(with: controlPanel)
        }

        if let shadowOverlay = config.shadowOverlay {
            configureShadowOverlay(with: shadowOverlay)
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

    func configurePreviewImage() {
        addSubview(previewImage)
        stretch(view: previewImage)
    }

    func configureErrorView(with config: KinescopeErrorViewConfiguration) {
        let errorView = ErrorView(config: config, delegate: self)
        addSubview(errorView)
        stretch(view: errorView)
        errorView.isHidden = true

        self.errorView = errorView
    }

    func configureProgressView(with progressView: KinescopeActivityIndicator) {
        addSubview(progressView)
        centerChild(view: progressView)
        NSLayoutConstraint.activate([
            progressView.widthAnchor.constraint(equalToConstant: progressView.frame.width),
            progressView.heightAnchor.constraint(equalToConstant: progressView.frame.height)
        ])
        progressView.isHidden = true
        self.progressView = progressView
    }

    func configurePip() {
        pipController = AVPictureInPictureController(playerLayer: playerView.playerLayer)
    }

    func configureNameView(with config: KinescopePlayerViewConfiguration) {
        let nameView = VideoNameView(config: config.nameConfiguration)
        addSubview(nameView)
        topChildWithSafeArea(view: nameView)
        nameView.alpha = 0.0
        self.nameView = nameView
        self.nameDisplayingType = config.nameDisplayingType
    }

    func configureControlPanel(with config: KinescopeControlPanelConfiguration) {
        let controlPanel = PlayerControlView(config: config)
        controlPanel.alpha = .zero
        addSubview(controlPanel)
        bottomChildWithSafeArea(view: controlPanel)

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

    func configureShadowOverlay(with config: KinescopePlayerShadowOverlayConfiguration) {
        let overlay = PlayerShadowOverlayView(config: config, delegate: self)
        overlay.isHidden = true
        addSubview(overlay)
        stretch(view: overlay)

        self.shadowOverlay = overlay
    }

    func updateViewState() {
        if progressView.superview == nil {
            configureProgressView(with: progressView)
        }
        errorView?.isHidden = true
        overlay?.isHidden = false
        nameView?.isHidden = false
        switch state {
        case .initialLoading:
            previewImage.isHidden = false
            progressView.showLoading(true)
            playPauseReplayState = .loading
        case .loading:
            previewImage.isHidden = true
            progressView.showLoading(true)
            playPauseReplayState = .loading
        case .playing:
            progressView.showLoading(false)
            previewImage.isHidden = true
            playPauseReplayState = .pause
            errorView?.isHidden = true
        case .paused:
            progressView.showLoading(false)
            playPauseReplayState = .play
        case .error:
            progressView.showLoading(false)
            previewImage.isHidden = true
            overlay?.isHidden = true
            nameView?.isHidden = true
            errorView?.isHidden = false
        case .ended:
            overlay?.playPauseReplayState = .replay
        }
    }

    func handleDisclosureActions(for title: String) {
        let model: SideMenu.Model
        switch SideMenu.Settings.getType(by: title) {
        case .playbackSpeed:
            model = .init(title: title, isRoot: false, isDownloadable: false, items: [])
        case .subtitles:
            model = makeSubtitlesSideMenuModel(with: title, root: false)
        case .quality:
            model = makeQualitySideMenuModel(with: title)
        case .none:
            model = .init(title: title, isRoot: false, isDownloadable: false, items: [])
        }

        presentSideMenu(model: model)
    }

    func handleDescriptionActions(for sideMenu: SideMenu, index: Int) {
        switch SideMenu.DescriptionTitle.getType(by: sideMenu.title) {
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

        let autoTitle = NSAttributedString(string: L10n.Player.auto)
        let selected = selectedQuality.string.hasPrefix(autoTitle.string)
        items.insert(.checkmark(title: autoTitle, selected: selected), at: 0)
        return .init(title: title, isRoot: false, isDownloadable: false, items: items)
    }

    func makeSubtitlesSideMenuModel(with title: String, root: Bool) -> SideMenu.Model {
        let subtitles = delegate?.didShowSubtitles() ?? []
        var items = subtitles.compactMap { subtitle -> SideMenu.Item in
            let selected = self.selectedSubtitles.string.trimmingCharacters(in: .symbols) == subtitle
            return .checkmark(title: .init(string: subtitle), selected: selected)
        }

        let offTitle = NSAttributedString(string: L10n.Player.off)
        let selected = selectedSubtitles.string == offTitle.string
        items.insert(.checkmark(title: offTitle, selected: selected), at: 0)
        return .init(title: title, isRoot: root, isDownloadable: false, items: items)
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

        for material in materials {
            let title = material.quality
            let value = bcf.string(fromByteCount: Int64(material.fileSize))
            items.append(.description(title: title, value: value))
        }

        return items
    }

    func handleCheckmarkActions(for title: NSAttributedString, sideMenu: SideMenu) {
        switch SideMenu.Settings.getType(by: sideMenu.title) {
        case .quality:
            handleQualityCheckmarkAction(for: title, sideMenu: sideMenu)
        case .subtitles:
            handleSubtitlesCheckmarkAction(for: title, sideMenu: sideMenu)
        case .playbackSpeed, .none:
            break
        }
    }

    func handleQualityCheckmarkAction(for title: NSAttributedString, sideMenu: SideMenu) {
        delegate?.didSelect(quality: title.string)
        sideMenuWillBeDismissed(sideMenu, withRoot: true)
        set(quality: title.string)
    }

    func handleSubtitlesCheckmarkAction(for title: NSAttributedString, sideMenu: SideMenu) {
        delegate?.didSelect(subtitles: title.string)
        sideMenuWillBeDismissed(sideMenu, withRoot: true)
        set(subtitles: title.string)
    }

    func set(quality: String) {
        let color = config.sideMenu.item.valueColor
        let font = config.sideMenu.item.valueFont
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        selectedQuality = quality.attributedStringWithAssetIconIfNeeded(attributes: attributes)
    }

    func set(subtitles: String) {
        let color = config.sideMenu.item.valueColor
        let font = config.sideMenu.item.valueFont
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        selectedSubtitles = NSAttributedString(string: subtitles, attributes: attributes)
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
        shadowOverlay.isHidden = false
        UIView.animate(withDuration: 0.2,
                       animations: {
                        shadowOverlay.alpha = 1
                       })
    }

    func hideShadow() {
        guard let shadowOverlay = shadowOverlay else {
            return
        }
        UIView.animate(withDuration: 0.2,
                       animations: {
                        shadowOverlay.alpha = 0
                       }, completion: { _ in
                        shadowOverlay.isHidden = false
                       })
    }

    func addDebouncerHandler() {
        overlayDebouncer.handler = { [weak self] in
            guard let self = self else {
                return
            }
            self.overlay?.isSelected = false
            UIView.animate(withDuration: 0.3, animations: {
                self.controlPanel?.alpha = 0.0
            }, completion: { _ in
                self.controlPanel?.expanded = false
            })
        }
    }

    func addTimelineDebouncerHandler() {
        if !(overlay?.isSelected ?? false) {
            timelineDebouncer.handler = { [weak self] in
                guard let self = self else {
                    return
                }
                UIView.animate(withDuration: 0.3, animations: {
                    self.controlPanel?.alpha = 0.0
                }, completion: { _ in
                    self.controlPanel?.expanded = false
                })
            }
            timelineDebouncer.renewInterval()
            UIView.animate(withDuration: 0.3, animations: {
                self.controlPanel?.alpha = 1.0
            })
        }
    }

}

// MARK: - PlayerOverlayViewDelegate

extension KinescopePlayerView: PlayerOverlayViewDelegate {

    func didTap(isSelected: Bool) {
        if isSelected {
            if !(controlPanel?.expanded ?? true) {
                overlay?.isSelected = false
                UIView.animate(withDuration: 0.3) {
                    self.controlPanel?.alpha = 0.0
                }
            } else {
                controlPanel?.expanded = false
            }
        } else {
            overlay?.isSelected = true
            UIView.animate(withDuration: 0.3) {
                self.controlPanel?.alpha = 1.0
            }
            addDebouncerHandler()
        }
        overlayDebouncer.renewInterval()
    }

    func didPlayPause() {
        if playPauseReplayState == .play {
            addDebouncerHandler()
            overlayDebouncer.renewInterval()
        } else {
            overlayDebouncer.handler = { }
        }
        delegate?.didPlayPause()
    }

    func didFastForward() {
        addTimelineDebouncerHandler()
        overlayDebouncer.renewInterval()
        delegate?.didFastForward()
    }

    func didFastBackward() {
        addTimelineDebouncerHandler()
        overlayDebouncer.renewInterval()
        delegate?.didFastBackward()
    }

    func didAlphaChanged(alpha: CGFloat) {
        nameView?.alpha = nameDisplayingType.convertAlpha(from: alpha)
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
                                                    value: nil),
                                        .disclosure(title: L10n.Player.subtitles,
                                                    value: selectedSubtitles),
                                        .disclosure(title: L10n.Player.videoQuality,
                                                    value: selectedQuality)
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
        case .description:
            handleDescriptionActions(for: sideMenu, index: rowIndex)
        }
    }

    func downloadAllTapped(for title: String) {
        delegate?.didSelectDownloadAll(for: title)
    }

}

// MARK: - ErorViewDelegate

extension KinescopePlayerView: ErrorViewDelegate {

    func didTapRefresh() {
        delegate?.didRefresh()
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
