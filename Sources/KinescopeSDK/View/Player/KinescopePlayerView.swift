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
    private var controlLeadingInset: NSLayoutConstraint?
    private var controlTrailingInset: NSLayoutConstraint?
    private var controlBottomInset: NSLayoutConstraint?
    private(set) weak var overlay: PlayerOverlayView?
    private(set) weak var errorOverlay: ErrorView?
    /// Shorts draws its own play button above the player. It hides that button while the error card is up.
    public var onPlaybackErrorVisibility: ((Bool) -> Void)?
    private(set) weak var announceSnack: AnnounceView?
    private(set) var progressView: KinescopeActivityIndicator!
    private(set) var shadowOverlay: PlayerShadowOverlayView?
    private(set) var subtitleOverlay: SubtitleOverlayView?
    private(set) var pipController: AVPictureInPictureController?

    private(set) var config: KinescopePlayerViewConfiguration!

    /// One coordination for phones and other for pads
    private let sideMenuCoordinator = SideMenuSlideCoordinator()
    /// Android template flag `playback_rate`. Hides the speed row in settings when false.
    public var showsPlaybackRateSetting = true

    private var playingRateProvider: SideMenuItemsProvider?
    private var qualityProvider: SideMenuItemsProvider?
    private var subtitlesProvider: SideMenuItemsProvider?
    private var scaleController: VideoScaleController?
    /// Clips the scaled video to the player. The surface inside it is what pinch zoom moves.
    private let videoCanvas = UIView()
    private let videoSurface = UIView()
    /// Wins over the navigation back-swipe so a horizontal seek does not slide the screen away.
    private var backSwipeClaim: UIPanGestureRecognizer?
    private var scrubHint: ScrubHintBar?
    /// Video surface stays covered until playback has actually started, same as Android.
    private(set) var isVideoPresented = false
    /// Live broadcast has not started: keep the awaiting cover up instead of a black frame.
    private(set) var keepsLiveCover = false
    /// While the screen is rotating into or out of fullscreen, playback status must not pop the seek bar back in.
    var suppressControlReveal = false
    /// Rotation is still moving the video. Controls come back only after it settles.
    var holdsControlReveal = false
    private var bufferingIndicatorWork: DispatchWorkItem?
    /// A format error can arrive while the picture is already moving. Confirm it is still failed before covering playback.
    private var pendingPlaybackError: DispatchWorkItem?
    /// Icon the viewer just asked for. Status events must not flip it back while the player catches up.
    private var requestedPlaying: Bool?

    private enum BufferingConstants {
        /// Shorter waits are treated as the normal hop back to `.playing` after pause.
        static let bufferingIndicatorDelay: TimeInterval = 0.4
    }

    // Phase 2 chrome state, pushed by player.
    var chapters: [KinescopeChapterMark] = []
    var chaptersDuration: TimeInterval = 0
    var playbackTime: TimeInterval = 0 {
        didSet {
            captionsSearch?.update(time: playbackTime)
        }
    }
    private var playlistSheet: PlaylistSheetView?
    private var captionsSearch: CaptionsSearchView?
    var audioTracks: [String] = []
    var selectedAudioTrack: Int?
    var playlist: [KinescopePlaylistItem] = []
    var currentPlaylistItemId: String?
    var subtitleCues: [SubtitleCue] = []
    var subtitleStyle = SubtitleStyle()

    private lazy var overlayDebouncer = Debouncer(
        timeInterval: config.controlPanel?.hideOnPlayTimeout ?? overlay?.duration ?? 0.0
    )

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
        bindSideMenuBackdrop()
        setLayout(with: .default)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        bindSideMenuBackdrop()
        setLayout(with: .default)
    }

    private func bindSideMenuBackdrop() {
        sideMenuCoordinator.hooks.onBackdrop = { [weak self] in
            guard let self, let menu = self.sideMenuCoordinator.menus(anchoredTo: self).last else {
                return
            }
            self.sideMenuWillBeDismissed(menu, withRoot: true)
        }
    }

    deinit {
        // Workaround to prevent plaing audio when player deinited(due to enabled background mode)
        if !(pipController?.isPictureInPictureActive ?? false) {
            playerView.player?.pause()
        }
    }

    public override func layoutSubviews() {
        updateControlInsets()
        super.layoutSubviews()
        sideMenuCoordinator.layout(in: self)
    }

    public override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        updateControlInsets()
    }

    /// Keep the buttons on the bottom edge. Ignore insets that would crush the bar into the center
    /// after a landscape fullscreen returns to the portrait player.
    private func updateControlInsets() {
        guard bounds.width > 1, bounds.height > 1 else {
            return
        }
        let insets = safeAreaInsets
        let horizontalOverflow = insets.left + insets.right > bounds.width * 0.45
        let verticalOverflow = insets.bottom > bounds.height * 0.45
        let leading = horizontalOverflow ? 0 : insets.left
        let trailing = horizontalOverflow ? 0 : -insets.right
        let bottom = verticalOverflow ? 0 : -insets.bottom
        guard controlLeadingInset?.constant != leading
                || controlTrailingInset?.constant != trailing
                || controlBottomInset?.constant != bottom else {
            return
        }
        controlLeadingInset?.constant = leading
        controlTrailingInset?.constant = trailing
        controlBottomInset?.constant = bottom
    }

    // MARK: - Internal Methods

    func startLoader() {
        overlay?.isHidden = true
        if !isVideoPresented {
            previewView.isHidden = false
            playerView?.isHidden = true
        }
        // The awaiting cover replaces the spinner, same as the Android live informer.
        progressView.showVideoProgress(isLoading: !keepsLiveCover)
    }

    func stopLoader(withPreview: Bool = true) {
        progressView.showVideoProgress(isLoading: false)
        previewView.isHidden = isVideoPresented || withPreview
        if isVideoPresented {
            playerView?.isHidden = false
        }
        overlay?.isHidden = false
    }

    /// Full-frame stand-in while a live broadcast has not started.
    func showLiveAwaitingCover() {
        keepsLiveCover = true
        isVideoPresented = false
        previewView.accessibilityIdentifier = "liveAwaitingCover"
        previewView.contentMode = .scaleAspectFill
        previewView.image = .image(named: "liveAwaitingCover")
        previewView.isHidden = false
        playerView?.isHidden = true
        progressView.showVideoProgress(isLoading: false)
        if let announceSnack {
            bringSubviewToFront(announceSnack)
        }
    }

    /// Drops the poster and shows the player layer. Called on the first `.playing` status.
    func revealVideo() {
        keepsLiveCover = false
        isVideoPresented = true
        previewView.isHidden = true
        playerView?.isHidden = false
        announceSnack?.hideAnimated()
        hidePlaybackError()
    }

    func change(timeControlStatus: AVPlayer.TimeControlStatus) {
        switch timeControlStatus {
        case .playing:
            cancelPendingBufferingIndicator()
            hidePlaybackError()
            overlay?.isHidden = false
            if requestedPlaying != false {
                requestedPlaying = nil
                overlay?.set(playing: true)
            }
            // A faded-out bar was hidden on purpose. Unhiding it here brought the controls
            // back on every buffering hiccup, and left them invisible when alpha was still 0.
            // The first time the bar appears it is still at full alpha and hidden, so the
            // center button and the title come up with it instead of waiting for a tap.
            if !suppressControlReveal, let panel = controlPanel, panel.alpha > 0.01 {
                if panel.isHidden {
                    revealControls(autoHide: true)
                } else {
                    panel.isHidden = false
                }
            }
            progressView.showVideoProgress(isLoading: false)
        case .paused:
            cancelPendingBufferingIndicator()
            if requestedPlaying != true {
                requestedPlaying = nil
                overlay?.set(playing: false)
            }
        case .waitingToPlayAtSpecifiedRate:
            // Play and pause already updated the icon. This state is only a short hop
            // back to playback, so it must not flip the icon or flash the spinner.
            scheduleBufferingIndicator()
        @unknown default:
            break
        }
    }

    private func scheduleBufferingIndicator() {
        guard bufferingIndicatorWork == nil else {
            return
        }
        let work = DispatchWorkItem { [weak self] in
            guard let self else {
                return
            }
            self.bufferingIndicatorWork = nil
            self.progressView.showVideoProgress(isLoading: true)
        }
        bufferingIndicatorWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + BufferingConstants.bufferingIndicatorDelay, execute: work)
    }

    private func cancelPendingBufferingIndicator() {
        bufferingIndicatorWork?.cancel()
        bufferingIndicatorWork = nil
    }

    func showReplay() {
        overlay?.showReplay()
        overlay?.isSelected = true
        controlPanel?.isHidden = false
        controlPanel?.showAnimated()
        overlayDebouncer.handler = { }
    }

    func showSubtitle(_ text: String?) {
        subtitleOverlay?.set(text: text)
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
        if let preview, let url = URL(string: preview), url.isFileURL,
           let image = UIImage(contentsOfFile: url.path) {
            previewView.accessibilityIdentifier = preview
            previewView.contentMode = .scaleAspectFit
            previewView.image = image
            if !isVideoPresented {
                previewView.isHidden = false
            }
            return
        }
        if let preview, let previewService = config.previewService {
            previewService.fetchPreview(for: preview, into: previewView)
        } else {
            previewView.accessibilityIdentifier = nil
            previewView.contentMode = .scaleAspectFit
            previewView.image = .image(named: "defaultPoster")
        }
        if !isVideoPresented {
            previewView.isHidden = false
        }
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        guard let claim = backSwipeClaim else {
            return
        }
        var responder: UIResponder? = self
        while let next = responder?.next {
            if let navigation = next as? UINavigationController {
                navigation.interactivePopGestureRecognizer?.require(toFail: claim)
                break
            }
            responder = next
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
        configureSubtitleOverlay()
        configurePip()
        configureScaleController()
        configureScrubHint()
        installBackSwipeClaim()
    }

    /// Show/hide player view overlay
    /// - Parameter shown: if true - show, hide otherwise
    func showOverlay(_ shown: Bool) {
        didTap(isSelected: !shown)
    }

    /// Drops the pause card and the bottom bar without the show-then-hide flash of a rotation.
    /// The overlay itself stays on screen so the next tap can bring the controls back.
    func dismissTransientChrome() {
        overlayDebouncer.handler = { }
        overlay?.isHidden = false
        overlay?.isUserInteractionEnabled = true
        overlay?.hideContentImmediately()
        controlPanel?.setVisible(false, animated: false)
    }

    /// Center button, seek bar and the gradient bands, after fullscreen has finished moving.
    public func revealControls(autoHide: Bool) {
        overlayDebouncer.handler = { }
        overlay?.isHidden = false
        overlay?.isUserInteractionEnabled = true
        overlay?.isSelected = true
        controlPanel?.setVisible(true, animated: false)
        controlPanel?.expanded = false
        guard autoHide, config.controlPanel?.hideOnPlayTimeout != nil else {
            return
        }
        addDebouncerHandler()
        overlayDebouncer.renewInterval()
    }

    /// Seek bar and the buttons next to it, without the center pause card.
    func showSeekBar() {
        overlayDebouncer.handler = { }
        overlay?.isHidden = false
        overlay?.isUserInteractionEnabled = true
        overlay?.hideContentImmediately()
        controlPanel?.setVisible(true, animated: false)
    }

    /// Looped playback swaps the queue player. The layer and PiP follow the new one.
    func replacePlayer(_ player: AVPlayer) {
        playerView.player = player
        guard pipController != nil, pipController?.isPictureInPictureActive != true else {
            return
        }
        configurePip()
    }

    func warmPlaylistSheet() {
        guard !playlist.isEmpty else {
            return
        }
        ensurePlaylistSheet().preload(items: playlist, selectedId: currentPlaylistItemId)
    }

    /// Covers the video only when playback is actually stopped. A transient parse error must not sit on a playing picture.
    func displayPlaybackError(_ error: Error) {
        pendingPlaybackError?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self else { return }
            let player = self.playerView.player
            let playing = player?.timeControlStatus == .playing || (player?.rate ?? 0) > 0
            let ready = player?.currentItem?.status == .readyToPlay && self.isVideoPresented
            if playing || ready {
                self.hidePlaybackError()
                return
            }
            self.errorOverlay?.display(error: error)
            self.onPlaybackErrorVisibility?(true)
        }
        pendingPlaybackError = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45, execute: work)
    }

    func hidePlaybackError() {
        pendingPlaybackError?.cancel()
        pendingPlaybackError = nil
        onPlaybackErrorVisibility?(false)
        guard let errorOverlay, !errorOverlay.isHidden else { return }
        errorOverlay.hideAnimated()
    }

}

// MARK: - Private

private extension KinescopePlayerView {

    func clearSubviews() {
        scaleController?.invalidate()
        scaleController = nil
        playlistSheet = nil
        captionsSearch = nil
        subviews.forEach {
            $0.removeFromSuperview()
        }
    }

    func configureScrubHint() {
        guard config.controlPanel != nil else { return }
        let hint = ScrubHintBar()
        hint.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hint)
        NSLayoutConstraint.activate([
            hint.topAnchor.constraint(equalTo: topAnchor),
            hint.leadingAnchor.constraint(equalTo: leadingAnchor),
            hint.trailingAnchor.constraint(equalTo: trailingAnchor),
            hint.heightAnchor.constraint(equalToConstant: 120)
        ])
        scrubHint = hint
    }

    func installBackSwipeClaim() {
        guard backSwipeClaim == nil else {
            return
        }
        let pan = UIPanGestureRecognizer(target: self, action: #selector(ignoreHorizontalPan))
        pan.cancelsTouchesInView = false
        pan.delaysTouchesBegan = false
        pan.delegate = self
        addGestureRecognizer(pan)
        backSwipeClaim = pan
    }

    @objc
    func ignoreHorizontalPan(_ recognizer: UIPanGestureRecognizer) {
    }

    func configureScaleController() {
        scaleController?.invalidate()
        let controller = VideoScaleController(container: self, target: videoSurface)
        controller.isTouchExcluded = { [weak self] touch in
            guard let self, let view = touch.view else {
                return false
            }
            var node: UIView? = view
            while let current = node, current !== self {
                if current is SideMenu || current === self.controlPanel || current === self.errorOverlay {
                    return true
                }
                node = current.superview
            }
            return false
        }
        scaleController = controller
    }

    func configurePlayerView(with gravity: AVLayerVideoGravity) {
        videoCanvas.subviews.forEach { $0.removeFromSuperview() }
        videoCanvas.clipsToBounds = true
        videoCanvas.backgroundColor = .black
        addSubview(videoCanvas)
        stretch(view: videoCanvas)

        videoSurface.subviews.forEach { $0.removeFromSuperview() }
        videoSurface.transform = .identity
        videoSurface.backgroundColor = .clear
        videoCanvas.addSubview(videoSurface)
        videoCanvas.stretch(view: videoSurface)

        let playerView = PlayerView()
        playerView.playerLayer.videoGravity = gravity
        playerView.isHidden = true
        videoSurface.addSubview(playerView)
        videoSurface.stretch(view: playerView)

        self.playerView = playerView
    }

    func configurePreviewView() {
        previewView.contentMode = .scaleAspectFit
        previewView.isUserInteractionEnabled = false
        previewView.clipsToBounds = true
        previewView.backgroundColor = .black
        previewView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        previewView.setContentHuggingPriority(.defaultLow, for: .vertical)
        previewView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        previewView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        videoSurface.addSubview(previewView)
        videoSurface.stretch(view: previewView)
    }

    func configureProgressView(with progressView: KinescopeActivityIndicator) {
        addSubview(progressView)
        centerChild(view: progressView)

        self.progressView = progressView
    }

    func configureSubtitleOverlay() {
        let overlay = SubtitleOverlayView()
        addSubview(overlay)
        stretch(view: overlay)
        overlay.onTap = { [weak self] in
            self?.openCaptionSearch()
        }
        subtitleOverlay = overlay
    }

    func openCaptionSearch() {
        guard !subtitleCues.isEmpty else {
            return
        }
        if let menu = sideMenuCoordinator.menus(anchoredTo: self).first {
            sideMenuWillBeDismissed(menu, withRoot: true)
        }
        let search = captionsSearch ?? {
            let view = CaptionsSearchView()
            view.onSeek = { [weak self] seconds in
                self?.delegate?.didSeek(toTime: seconds)
            }
            addSubview(view)
            stretch(view: view)
            captionsSearch = view
            return view
        }()
        bringSubviewToFront(search)
        search.show(cues: subtitleCues, time: playbackTime)
    }

    func showPlaylist() {
        let sheet = ensurePlaylistSheet()
        bringSubviewToFront(sheet)
        sheet.show(items: playlist, selectedId: currentPlaylistItemId)
    }

    private func ensurePlaylistSheet() -> PlaylistSheetView {
        if let playlistSheet {
            return playlistSheet
        }
        let view = PlaylistSheetView()
        view.onSelect = { [weak self] item in
            self?.delegate?.didSelect(playlistItem: item)
        }
        view.onCopy = { item in
            if let link = item.shareUrl, !link.isEmpty {
                UIPasteboard.general.string = link
            }
        }
        addSubview(view)
        stretch(view: view)
        playlistSheet = view
        return view
    }

    func configurePip() {
        guard config.allowsPictureInPicture else {
            pipController?.delegate = nil
            pipController = nil
            return
        }
        pipController = AVPictureInPictureController(playerLayer: playerView.playerLayer)
    }

    func configureControlPanel(with config: KinescopeControlPanelConfiguration) {
        let controlPanel = PlayerControlView(config: config)
        addSubview(controlPanel)
        controlPanel.translatesAutoresizingMaskIntoConstraints = false
        let leading = controlPanel.leadingAnchor.constraint(equalTo: leadingAnchor)
        let trailing = controlPanel.trailingAnchor.constraint(equalTo: trailingAnchor)
        let bottom = controlPanel.bottomAnchor.constraint(equalTo: bottomAnchor)
        NSLayoutConstraint.activate([leading, trailing, bottom])
        controlLeadingInset = leading
        controlTrailingInset = trailing
        controlBottomInset = bottom
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
        case .audio:
            model = makeAudioSideMenuModel()
        case .subtitleLook:
            model = makeSubtitleLookModel()
        case .fontColor:
            model = makeSubtitleColorModel(title: title, background: false)
        case .fontSize:
            model = makeSubtitleSizeModel()
        case .backgroundColor:
            model = makeSubtitleColorModel(title: title, background: true)
        case .backgroundOpacity:
            model = makeSubtitleOpacityModel()
        case .videoScale:
            model = makeScaleSideMenuModel()
        case .subtitleSearch:
            model = nil
        case .chapters, .playlist, .none:
            model = nil
        }
        
        if SideMenu.Settings.getType(by: title) == .subtitleSearch {
            openCaptionSearch()
            return
        }
        guard let model else {
            return
        }

        presentSideMenu(model: model)
        if SideMenu.Settings.getType(by: title) == .videoScale {
            sideMenuCoordinator.menus(anchoredTo: self).last?
                .setDisplayedTitle("\(L10n.Player.scale)  \(scaleController?.percentText ?? "100%")")
        }
    }

    func handleDescriptionActions(for sideMenu: SideMenu, id: String) {
        switch SideMenu.DescriptionTitle.getType(by: sideMenu.title) {
        case .attachments:
            delegate?.didSelectAttachment(with: id)
            sideMenuWillBeDismissed(sideMenu, withRoot: true)
        case .download:
            delegate?.didSelect(quality: id)
            sideMenuWillBeDismissed(sideMenu, withRoot: true)
        case .subtitleSearch:
            if let seconds = TimeInterval(id) {
                delegate?.didSeek(toTime: seconds)
            }
            sideMenuWillBeDismissed(sideMenu, withRoot: true)
        case .chapters:
            if let seconds = TimeInterval(id), chaptersDuration > 0 {
                delegate?.didSeek(to: seconds / chaptersDuration)
                delegate?.didConfirmSeek()
            }
            sideMenuWillBeDismissed(sideMenu, withRoot: true)
        case .none:
            return
        }

    }

    func makeScaleSideMenuModel() -> SideMenu.Model {
        .init(title: L10n.Player.scale,
              isRoot: false,
              isDownloadable: false,
              items: [
                .description(id: "down", title: L10n.Player.scaleDecrease, value: ""),
                .description(id: "up", title: L10n.Player.scaleIncrease, value: ""),
                .description(id: "reset", title: L10n.Player.scaleReset, value: "")
              ],
              showsCloseButton: false)
    }

    func makeSpeedSideMenuModel(with title: String) -> SideMenu.Model {
        .init(title: title,
              isRoot: false,
              isDownloadable: false,
              items: playingRateProvider?.items ?? [],
              showsCloseButton: false)
    }

    func makeQualitySideMenuModel(with title: String) -> SideMenu.Model {
        .init(title: title,
              isRoot: false,
              isDownloadable: false,
              items: qualityProvider?.items ?? [],
              showsCloseButton: false)
    }

    func makeSubtitlesSideMenuModel(with title: String, root: Bool) -> SideMenu.Model {
        var items = subtitlesProvider?.items ?? []
        items.append(.disclosure(title: L10n.Player.subtitleLook, value: nil, icon: nil))
        if !subtitleCues.isEmpty {
            items.append(.disclosure(title: L10n.Player.subtitleSearch,
                                     value: nil,
                                     icon: .image(named: "search")))
        }
        return .init(title: title, isRoot: root, isDownloadable: false, items: items, showsCloseButton: false)
    }

    func makeSubtitleLookModel() -> SideMenu.Model {
        .init(title: L10n.Player.subtitleLook, isRoot: false, isDownloadable: false, items: [
            .disclosure(title: L10n.Player.fontColor,
                        value: formatValue(subtitleStyle.colorName(for: subtitleStyle.fontColor))),
            .disclosure(title: L10n.Player.fontSize,
                        value: formatValue("\(subtitleStyle.fontSizePercent)%")),
            .disclosure(title: L10n.Player.backgroundColor,
                        value: formatValue(subtitleStyle.colorName(for: subtitleStyle.backgroundColor))),
            .disclosure(title: L10n.Player.backgroundOpacity,
                        value: formatValue("\(subtitleStyle.backgroundOpacityPercent)%")),
            .checkmark(title: NSAttributedString(string: L10n.Player.reset), selected: false)
        ], showsCloseButton: false)
    }

    func makeSubtitleColorModel(title: String, background: Bool) -> SideMenu.Model {
        let selected = background ? subtitleStyle.backgroundColor : subtitleStyle.fontColor
        let items = SubtitleStyle.colors.map { option in
            SideMenu.Item.checkmark(title: NSAttributedString(string: option.name),
                                    selected: option.color.matchesRGB(selected))
        }
        return .init(title: title, isRoot: false, isDownloadable: false, items: items, showsCloseButton: false)
    }

    func makeSubtitleSizeModel() -> SideMenu.Model {
        let items = SubtitleStyle.fontSizes.map { size in
            SideMenu.Item.checkmark(title: NSAttributedString(string: "\(size)%"),
                                    selected: size == subtitleStyle.fontSizePercent)
        }
        return .init(title: L10n.Player.fontSize, isRoot: false, isDownloadable: false, items: items, showsCloseButton: false)
    }

    func makeSubtitleOpacityModel() -> SideMenu.Model {
        let items = SubtitleStyle.opacities.map { value in
            SideMenu.Item.checkmark(title: NSAttributedString(string: "\(value)%"),
                                    selected: value == subtitleStyle.backgroundOpacityPercent)
        }
        return .init(title: L10n.Player.backgroundOpacity, isRoot: false, isDownloadable: false, items: items, showsCloseButton: false)
    }

    func makeSubtitleSearchModel() -> SideMenu.Model {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        let items = subtitleCues.map { cue -> SideMenu.Item in
            let text = cue.lines.joined(separator: " ")
            let clock = formatter.string(from: cue.start) ?? ""
            return .description(id: String(cue.start), title: text, value: clock)
        }
        return .init(title: L10n.Player.subtitleSearch,
                     isRoot: false,
                     isDownloadable: false,
                     items: items,
                     showsSearch: true,
                     showsCloseButton: false)
    }

    func makeAudioSideMenuModel() -> SideMenu.Model {
        let items: [SideMenu.Item] = audioTracks.enumerated().map { index, title in
            .checkmark(title: NSAttributedString(string: title), selected: index == selectedAudioTrack)
        }
        return .init(title: L10n.Player.audio, isRoot: false, isDownloadable: false, items: items, showsCloseButton: false)
    }

    func makeChaptersSideMenuModel() -> SideMenu.Model {
        let items: [SideMenu.Item] = chapters.enumerated().map { index, chapter in
            .description(id: String(chapter.start),
                         title: "\(index + 1). \(chapter.title)",
                         value: formatPlayerTime(chapter.start))
        }
        return .init(title: L10n.Player.chapters, isRoot: true, isDownloadable: false, items: items)
    }

    func makePlaylistSideMenuModel() -> SideMenu.Model {
        let items: [SideMenu.Item] = playlist.map { item in
            .checkmark(title: NSAttributedString(string: item.title),
                       selected: item.id == currentPlaylistItemId)
        }
        return .init(title: L10n.Player.playlist, isRoot: true, isDownloadable: false, items: items)
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

    func handleCheckmarkActions(for title: NSAttributedString, rowIndex: Int, sideMenu: SideMenu) {
        switch SideMenu.Settings.getType(by: sideMenu.title) {
        case .quality:
            delegate?.didSelect(quality: title.string)
        case .subtitles:
            delegate?.didSelect(subtitles: title.string)
        case .playbackSpeed:
            delegate?.didSelect(rate: KinescopePlayingRate.from(string: title.string).rawValue)
        case .audio:
            delegate?.didSelect(audioTrack: rowIndex)
        case .chapters:
            if chapters.indices.contains(rowIndex), chaptersDuration > 0 {
                delegate?.didSeek(to: chapters[rowIndex].start / chaptersDuration)
                delegate?.didConfirmSeek()
            }
        case .playlist:
            if playlist.indices.contains(rowIndex) {
                delegate?.didSelect(playlistItem: playlist[rowIndex])
            }
        case .subtitleLook:
            guard title.string == L10n.Player.reset else {
                return
            }
            subtitleStyle = SubtitleStyle()
            delegate?.didUpdate(subtitleStyle: subtitleStyle)
        case .fontColor:
            applySubtitleColor(named: title.string, background: false)
        case .fontSize:
            if let size = Int(title.string.replacingOccurrences(of: "%", with: "")) {
                subtitleStyle.fontSizePercent = size
                delegate?.didUpdate(subtitleStyle: subtitleStyle)
            }
        case .backgroundColor:
            applySubtitleColor(named: title.string, background: true)
        case .backgroundOpacity:
            if let value = Int(title.string.replacingOccurrences(of: "%", with: "")) {
                subtitleStyle.backgroundOpacityPercent = value
                delegate?.didUpdate(subtitleStyle: subtitleStyle)
            }
        case .videoScale, .subtitleSearch, .none:
            break
        }
        sideMenuWillBeDismissed(sideMenu, withRoot: true)
    }
    
    func applySubtitleColor(named name: String, background: Bool) {
        guard let color = SubtitleStyle.colors.first(where: { $0.name == name })?.color else {
            return
        }
        if background {
            subtitleStyle.backgroundColor = color
        } else {
            subtitleStyle.fontColor = color
        }
        delegate?.didUpdate(subtitleStyle: subtitleStyle)
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
            guard self.config.controlPanel?.hideOnPlayTimeout != nil else {
                return
            }
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
                if config.controlPanel?.hideOnPlayTimeout != nil {
                    controlPanel?.hideAnimated()
                }
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
        requestedPlaying = true
        cancelPendingBufferingIndicator()
        progressView.showVideoProgress(isLoading: false)
        overlay?.set(playing: true)
        addDebouncerHandler()
        overlayDebouncer.renewInterval()
        delegate?.didPlay()
    }

    func didPause() {
        requestedPlaying = false
        cancelPendingBufferingIndicator()
        progressView.showVideoProgress(isLoading: false)
        overlay?.set(playing: false)
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

    func didTouchVideo() {
        delegate?.didTouchVideo()
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
        case .chapters:
            presentSideMenu(model: makeChaptersSideMenuModel())
        case .playlist:
            showPlaylist()
        case .settings:
            var items: [SideMenu.Item] = []
            if showsPlaybackRateSetting {
                items.append(.disclosure(title: L10n.Player.playbackSpeed,
                                         value: formatValue(playingRateProvider?.selectedTitle),
                                         icon: .image(named: "menuSpeed")))
            }
            items.append(contentsOf: [
                .disclosure(title: L10n.Player.subtitles,
                            value: formatValue(subtitlesProvider?.selectedTitle),
                            icon: .image(named: "menuSubtitles")),
                .disclosure(title: L10n.Player.videoQuality,
                            value: formatValue(qualityProvider?.selectedTitle),
                            icon: .image(named: "menuQuality"))
            ])
            if audioTracks.count > 1 {
                let selected = selectedAudioTrack.flatMap { audioTracks.indices.contains($0) ? audioTracks[$0] : nil }
                let insertAt = min(showsPlaybackRateSetting ? 2 : 1, items.count)
                items.insert(.disclosure(title: L10n.Player.audio,
                                         value: formatValue(selected),
                                         icon: .image(named: "menuAudio")),
                             at: insertAt)
            }
            items.append(.disclosure(title: L10n.Player.scale,
                                     value: formatValue(scaleController?.percentText ?? "100%"),
                                     icon: .image(named: "menuScale")))
            let model = SideMenu.Model(title: L10n.Player.settings,
                                       isRoot: true,
                                       isDownloadable: false,
                                       items: items,
                                       showsCloseButton: false)
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
            if subtitleCues.isEmpty {
                presentSideMenu(model: makeSubtitlesSideMenuModel(with: L10n.Player.subtitles, root: true))
            } else {
                openCaptionSearch()
            }
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
        overlay?.setCenterButtonHidden(true)
        scrubHint?.show()
        delegate?.didSeek(to: Double(position))
        overlayDebouncer.renewInterval()
    }

    func onUpdate() {
        overlay?.setCenterButtonHidden(false)
        scrubHint?.hide()
        delegate?.didConfirmSeek()
        overlayDebouncer.renewInterval()
    }

    func didTapLive() {
        overlayDebouncer.renewInterval()
        delegate?.didSeekToLive()
    }

}

// MARK: - SideMenuDelegate

extension KinescopePlayerView: SideMenuDelegate {

    func sideMenuWillBeDismissed(_ sideMenu: SideMenu, withRoot: Bool) {
        if withRoot {
            hideShadow()
            // Drop the pages underneath first. Animating them too slides the
            // previous page back into view and only then closes the card.
            let menus = sideMenuCoordinator.menus(anchoredTo: self)
            menus.dropLast().forEach { menu in
                sideMenuCoordinator.dismiss(view: menu, from: self, animated: false)
            }
            if let top = sideMenuCoordinator.menus(anchoredTo: self).last {
                sideMenuCoordinator.dismiss(view: top, from: self, animated: true)
            }
        } else {
            sideMenuCoordinator.dismiss(view: sideMenu, from: self, animated: true)
        }
    }

    func sideMenuDidSelect(item: SideMenu.Item, rowIndex: Int, sideMenu: SideMenu) {
        if case .description(let id, _, _) = item, sideMenu.title == L10n.Player.scale {
            switch id {
            case "down":
                scaleController?.multiply(by: 0.97)
            case "up":
                scaleController?.multiply(by: 1.03)
            default:
                scaleController?.reset(animated: true)
            }
            let percent = scaleController?.percentText ?? "100%"
            sideMenu.setDisplayedTitle("\(L10n.Player.scale)  \(percent)")
            sideMenuCoordinator.menus(anchoredTo: self).forEach {
                $0.setDisclosureValue(formatValue(percent), for: L10n.Player.scale)
            }
            return
        }
        switch item {
        case .disclosure(let title, _, _):
            handleDisclosureActions(for: title)
        case .checkmark(let title, _):
            handleCheckmarkActions(for: title, rowIndex: rowIndex, sideMenu: sideMenu)
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
        if let sideMenu = sideMenuCoordinator.menus(anchoredTo: self).first {
            sideMenuWillBeDismissed(sideMenu, withRoot: true)
        }
    }

}

extension KinescopePlayerView: UIGestureRecognizerDelegate {

    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === backSwipeClaim, let pan = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }
        let velocity = pan.velocity(in: self)
        return abs(velocity.x) > abs(velocity.y)
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                 shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

}

/// Top seek hint shown while the timeline is dragged. Matches the Android scrub header:
/// a top gradient, running rewind and forward chevrons, and the double-tap hint.
private final class ScrubHintBar: UIView {

    private let gradient = CAGradientLayer()
    private let backIcon = SeekChevronsView(forward: false)
    private let forwardIcon = SeekChevronsView(forward: true)
    private var showing = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
        alpha = 0
        isUserInteractionEnabled = false
        gradient.colors = [
            UIColor.black.withAlphaComponent(0.8).cgColor,
            UIColor.clear.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        layer.addSublayer(gradient)

        let title = UILabel()
        title.text = L10n.Player.scrubHint
        title.textColor = .white
        title.font = .systemFont(ofSize: 14)
        title.textAlignment = .center

        let row = UIStackView(arrangedSubviews: [backIcon, title, forwardIcon])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 8
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)
        backIcon.translatesAutoresizingMaskIntoConstraints = false
        forwardIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            row.centerXAnchor.constraint(equalTo: centerXAnchor),
            row.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
            backIcon.widthAnchor.constraint(equalToConstant: 28),
            backIcon.heightAnchor.constraint(equalToConstant: 18),
            forwardIcon.widthAnchor.constraint(equalToConstant: 28),
            forwardIcon.heightAnchor.constraint(equalToConstant: 18)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }

    func show() {
        guard !showing else { return }
        showing = true
        isHidden = false
        superview?.bringSubviewToFront(self)
        layoutIfNeeded()
        backIcon.startRipple()
        forwardIcon.startRipple()
        UIView.animate(withDuration: 0.15) {
            self.alpha = 1
        }
    }

    func hide() {
        guard showing else { return }
        showing = false
        backIcon.stopRipple()
        forwardIcon.stopRipple()
        UIView.animate(withDuration: 0.15, animations: {
            self.alpha = 0
        }, completion: { _ in
            if !self.showing {
                self.isHidden = true
            }
        })
    }
}

