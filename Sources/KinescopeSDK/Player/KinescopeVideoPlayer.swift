import AVFoundation
import AVKit
import UIKit

public class KinescopeVideoPlayer: KinescopePlayer, KinescopePlayerBody, FullscreenStateProvider, PlayingRateSource, VideoQualitySource, SubtitlesSource {

    private enum Constants {
        static let periodicIntervalInSeconds: TimeInterval = 0.01
        static let viewThreshold: TimeInterval = 5
        static let minPlaybackThreshold: TimeInterval = 5
        static let maxPlaybackThreshold: TimeInterval = 60
    }

    public weak var pipDelegate: AVPictureInPictureControllerDelegate? {
        didSet {
            view?.pipController?.delegate = pipDelegate
        }
    }

    /// Show video info on Lock Screen and Control Center and handle remote commands
    /// (play, pause, ±10 seconds, scrubbing).
    /// Requires `playback` audio session category and background audio mode in host app.
    /// Only one player should have it enabled at the same time.
    public var isNowPlayingEnabled = false {
        didSet {
            guard oldValue != isNowPlayingEnabled else {
                return
            }
            if isNowPlayingEnabled {
                nowPlaying.activate()
                nowPlaying.loadArtwork(from: video.flatMap { posterSource(for: $0) })
                updateNowPlaying()
            } else {
                nowPlaying.deactivate()
            }
        }
    }

    /// `true` while video is actually playing (not paused and not waiting for data)
    public private(set) var isPlaying = false
    /// Set by play and pause. A stalled buffer must not resume a video the viewer paused.
    private(set) var wantsPlayback = false
    /// Metadata request already running. A second play() must not start another one.
    private var isLoadingVideo = false
    /// Bumped by stop() so a request that returns afterwards cannot bind a player.
    private var loadGeneration = 0
    private var didInstallLoopHandoff = false

    // MARK: - Private Properties
    
    public let config: KinescopePlayerConfig
    private let dependencies: KinescopePlayerDependencies
    
    private var analyticStorage: InnerEventsDataStorage & InnerEventsDataInputs = InMemoryInnerEventsDataStorage()
    private lazy var analytic: InnerEventsHandler? = Kinescope.analytic?.provide(with: analyticStorage)

    private let kvoBag = KVOBag()

    private lazy var notificationsBag = NotificationsBag(observer: self)
    
    @Repeating(executionQueue: .main, mode: .default)
    private var playRepeater

    private(set) lazy var strategy: PlayingStrategy = {
        dependencies.provide(for: config)
    }()

    private(set) weak var view: KinescopePlayerView?
    /// True after the picture has moved, so a new view does not flash the poster again.
    private var hasPresentedVideo = false
    /// Shorts drop their own cover. The picture shows on the first `.playing` status instead of after the playhead moves.
    private var revealsOnPlay = false
    /// Playback time when `.playing` started. The poster stays up until this moves,
    /// otherwise AVPlayer shows a still preview frame between the poster and the video.
    private var revealAnchor: TimeInterval?
    private var revealFallback: DispatchWorkItem?
    /// Paused because the app went to background. Stays paused when it returns.
    private var pausedForBackground = false

    private var time: TimeInterval = 0 {
        didSet {
            updateTimeline()
        }
    }

    @ApproxTimeInterval(step: Constants.periodicIntervalInSeconds)
    private var cachedDuration: TimeInterval = .nan

    private(set) var isLive = false {
        didSet {
            updateLiveIndicator()
        }
    }

    private var isSeeking = false
    private var isPreparingSeek = false
    /// When user seeks before duration is available, store position (0-1) and apply in didConfirmSeek.
    private var pendingSeekPosition: Double?
    /// Position requested via public `seek(to:)` before item became ready to play.
    private var pendingStartTime: TimeInterval?
    private var isOverlayed = false
    private var savedTime: CMTime = .zero
    private weak var miniView: KinescopePlayerView?
    private(set) weak var delegate: KinescopeVideoPlayerDelegate?

    private var drmHandler: DataProtectionHandler?

    private(set) var isFullScreenModeActive = false
    /// Portrait readings leave fullscreen only after the device has actually been landscape.
    /// A seek tap can post a portrait orientation event while the phone never left portrait.
    private var exitFullscreenOnPortrait = false
    private var portraitExit: DispatchWorkItem?
    private var ignorePortraitExitUntil: CFTimeInterval = 0
    private var playbackRate: Float = KinescopePlayingRate.normal.rawValue
    private(set) var currentQuality = L10n.Player.auto
    private(set) var currentSubtitles: String?
    private lazy var isLoopEnabled = config.looped
    /// Shorts cap the picture at 480, same as Android `setMaxVideoSize(854, 480)`.
    private var maximumPlaybackHeight: CGFloat = 0

    var currentRate: KinescopePlayingRate {
        KinescopePlayingRate(rawValue: playbackRate) ?? .normal
    }

    private lazy var stallWatchdog = PlaybackStallWatchdog(
        currentTime: { [weak self] in self?.currentTime ?? 0 },
        onStall: { [weak self] in self?.handlePlaybackStall() }
    )

    private lazy var nowPlaying = NowPlayingController(handlers: .init(
        play: { [weak self] in self?.didPlay() },
        pause: { [weak self] in self?.didPause() },
        seekTo: { [weak self] in self?.seek(to: $0) },
        seekBy: { [weak self] in self?.seek(by: $0) }
    ))

    private(set) var video: KinescopeVideo? {
        didSet {
            guard let video else {
                return
            }
            isLive = Self.isBroadcast(video) && strategy.player.isReadyToPlay
            audioGroup = nil
            audioOptions = []
            audioTrackTitles = []
            view?.audioTracks = []
            view?.selectedAudioTrack = nil
            subtitleTask?.cancel()
            subtitleCues = []
            view?.subtitleCues = []
            view?.showSubtitle(nil)
            drmHandler = dependencies.drmFactory.provide(for: video)
            analyticStorage.videoInput.setVideo(video)
            analyticStorage.sessionInput.resetWatchedDuration()
            analytic?.reset()
            if isNowPlayingEnabled {
                nowPlaying.loadArtwork(from: posterSource(for: video))
                updateNowPlaying()
            }
        }
    }

    private var playbackThreshold: TimeInterval {
        guard let duration = video?.duration, duration > 0 else {
            return Constants.minPlaybackThreshold
        }
        let threshold = duration * 0.02
        return threshold < Constants.maxPlaybackThreshold ? threshold : Constants.maxPlaybackThreshold
    }

    private var customOptions = [KinescopePlayerOption]()
    private var disabledOptions = [KinescopePlayerOption]()
    private var options = [KinescopePlayerOption]()

    fileprivate var playlist: [KinescopePlaylistItem] = []
    fileprivate var currentPlaylistItemId: String?
    fileprivate var audioGroup: AVMediaSelectionGroup?
    fileprivate var audioOptions: [AVMediaSelectionOption] = []
    fileprivate var audioTrackTitles: [String] = []
    fileprivate var presentationHeight: CGFloat = 0
    fileprivate var lastAutoHeightCheck: CFTimeInterval = 0
    private var subtitleStyle = SubtitleStyle()
    private var subtitleCues: [SubtitleCue] = []
    private var subtitleTask: URLSessionDataTask?
    
    private var playbackObserverFactory: (any Factory)?
    private var playbackObserver: Any?

    private var textStyleRules: [AVTextStyleRule]? {
        let pos = kCMTextMarkupAttribute_OrthogonalLinePositionPercentageRelativeToWritingDirection
        guard
            let rule = AVTextStyleRule(
                textMarkupAttributes: [
                    pos as String: 75.0,
                    kCMTextMarkupAttribute_BaseFontSizePercentageRelativeToVideoHeight as String: 10.0
                ]
            )
        else {
            return nil
        }

        return [rule]
    }

    var availableAssets: [KinescopeVideoAsset] {
        video?.downloadableAssets ?? []
    }

    var availableSubtitles: [String] {
        video?.allSubtitlesVariants ?? []
    }

    /// Stall watchdog should not fire while live stream is waiting for its start.
    private var isAwaitingLiveStart: Bool {
        Self.isAwaitingBroadcast(video)
    }

    /// Branded cover stays only until the scheduled start. An ongoing broadcast plays through.
    private static func isAwaitingBroadcast(_ video: KinescopeVideo?) -> Bool {
        guard isBroadcast(video), let startsAt = video?.live?.startsAt else {
            return false
        }
        return startsAt > Date()
    }

    private static func isBroadcast(_ video: KinescopeVideo?) -> Bool {
        video?.type == .live || video?.live != nil
    }

    // MARK: - Lifecycle

    init(config: KinescopePlayerConfig,
         dependencies: KinescopePlayerDependencies) {
        self.dependencies = dependencies
        self._playRepeater = Repeating(executionQueue: .main, mode: config.repeatingMode)
        self.config = config
        playRepeater = .init(title: "play") { [weak self] in
            guard self?.wantsPlayback == true else { return }
            self?.play()
        }
        addNotofications()
    }

    deinit {
        self.removePlaybackTimeObserver()
        self.kvoBag.removeAll()
        self.notificationsBag.removeAll()
        self.stallWatchdog.reset()
        self.$playRepeater.cancel()
        if isNowPlayingEnabled {
            self.nowPlaying.deactivate()
        }
    }

    // MARK: - KinescopePlayer

    public required convenience init(config: KinescopePlayerConfig) {
        self.init(config: config,
                  dependencies: KinescopeVideoPlayerDependencies())
        self.configureAnalytic()
    }

    public func play() {
        wantsPlayback = true
        installLoopHandoffIfNeeded()
        if let video {
            // Not ready yet usually means the item is still preparing.
            // Binding again here is what stacked two AVPlayerLoopers on one queue.
            if !strategy.hasBoundItem {
                if let localURL = config.localPlaybackURL {
                    select(quality: .downloaded(url: localURL))
                } else {
                    select(quality: .auto(hlsLink: video.hlsLink))
                }
            }
            self.strategy.play(with: playbackRate)
            self.delegate?.playerDidPlay()
        } else {
            self.load()
        }
    }

    public func pause() {
        wantsPlayback = false
        self.$playRepeater.cancel()
        self.stallWatchdog.reset()
        self.strategy.pause()
        self.delegate?.playerDidPause()
    }

    public func stop() {
        wantsPlayback = false
        loadGeneration += 1
        isLoadingVideo = false
        installLoopHandoffIfNeeded()
        self.$playRepeater.cancel()
        self.stallWatchdog.reset()
        self.strategy.pause()
        self.strategy.unbind()
        self.delegate?.playerDidStop()
    }

    /// Drops the item away from the main thread. `replaceCurrentItem(with: nil)` can stall the caller
    /// for seconds, which freezes a feed that is scrolling.
    public func relinquish() {
        wantsPlayback = false
        loadGeneration += 1
        isLoadingVideo = false
        installLoopHandoffIfNeeded()
        self.$playRepeater.cancel()
        self.stallWatchdog.reset()
        self.strategy.pause()
        removePlaybackTimeObserver()
        kvoBag.removeObserver(for: .playerTimeControlStatus)
        kvoBag.removeObserver(for: .playerStatus)
        kvoBag.removeObserver(for: .playerItem)
        kvoBag.removeObserver(for: .playerItemStatus)
        kvoBag.removeObserver(for: .playerItemBufferEmpty)
        kvoBag.removeObserver(for: .playerItemPresentationSize)
        let avPlayer = strategy.player
        let retained = self
        DispatchQueue.global(qos: .utility).async {
            avPlayer.replaceCurrentItem(with: nil)
            DispatchQueue.main.async {
                _ = retained
            }
        }
        delegate?.playerDidStop()
    }

    public func attach(view: KinescopePlayerView) {
        if self.view === view, view.playerView.player === strategy.player {
            return
        }
        analyticStorage.sessionInput.refreshViewId()
        
        view.bind(playingRateProvider: PlayingRateProvider(rateSource: self),
                  videoQualityProvider: VideoQualityProvider(source: self),
                  subtitlesProvider: SubtitlesProvider(source: self))

        view.playerView.player = self.strategy.player
        view.delegate = self
        self.view = view
        view.overlay?.isHidden = false
        view.overlay?.set(playing: isPlaying)
        view.layoutIfNeeded()
        if hasPresentedVideo {
            view.revealVideo()
        } else if Self.isAwaitingBroadcast(video) {
            view.showLiveAwaitingCover()
            view.announceSnack?.display(startsAt: video?.live?.startsAt)
        } else if let video {
            view.set(preview: posterSource(for: video))
        }
        view.set(options: options)
        view.controlPanel?.set(fullscreenOn: isFullScreenModeActive)
        applyChromeState(to: view)
        view.pipController?.delegate = pipDelegate
        updateTimeline()
        updateLiveIndicator()
        observePlaybackTime()
        addPlayerTimeControlStatusObserver()
        addPlayerStatusObserver()
        addPlayerItemObserver()
        addPlayerStatusObserver()
    }

    public func detach(view: KinescopePlayerView) {
        view.playerView.player = nil
        view.delegate = nil
        // Fullscreen teardown must not drop a player that already moved back inline.
        guard self.view === view else {
            return
        }
        self.view = nil

        removePlaybackTimeObserver()
        kvoBag.removeObserver(for: .playerTimeControlStatus)
        kvoBag.removeObserver(for: .playerStatus)
    }

    /// `auto`, a height such as `720` / `720p`, or `audio`. Unknown names fall back to auto.
    public func selectQuality(named name: String) {
        let normalized = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if normalized == "auto" || normalized.isEmpty {
            didSelect(quality: "Auto")
            return
        }
        if normalized == "audio" || normalized == "audio_only" || normalized == "audio-only" {
            didSelect(quality: "Audio")
            return
        }
        let digits = normalized.filter(\.isNumber)
        if let height = Int(digits), height > 0 {
            didSelect(quality: "\(height)p")
            return
        }
        didSelect(quality: name)
    }

    /// `none` keeps a short buffer, `metadata` lets AVPlayer decide, `auto` buffers ahead.
    public func setPreload(_ mode: String) {
        guard let item = strategy.player.currentItem else { return }
        switch mode.lowercased() {
        case "none":
            item.preferredForwardBufferDuration = 1
        case "auto":
            item.preferredForwardBufferDuration = 30
        default:
            item.preferredForwardBufferDuration = 0
        }
    }

    public func enterFullscreen() {
        guard let view else { return }
        didPresentFullscreen(from: view)
    }

    public func select(quality: KinescopeVideoQuality) {
        installLoopHandoffIfNeeded()

        savedTime = strategy.player.currentTime()

        if let item = quality.makeItem(with: drmHandler) {
            strategy.bind(item: item)
        }

        guard let item = strategy.player.currentItem else {
            return
        }
        item.preferredPeakBitRate = quality.preferredMaxBitRate
        item.preferredMaximumResolution = quality.preferredMaximumResolution
        applyMaximumVideoHeight(to: item)
        // A ceiling alone leaves the player on the variant it already buffered.
        let time = strategy.player.currentTime()
        if time.isValid, time.seconds.isFinite {
            strategy.player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        }
    }

    /// Prefers a modest rendition. Never a hard ceiling: a clip whose only variant is larger must still show a picture.
    public func setMaximumVideoHeight(_ height: CGFloat) {
        maximumPlaybackHeight = max(0, height)
        if let item = strategy.player.currentItem {
            applyMaximumVideoHeight(to: item)
        }
    }

    private func applyMaximumVideoHeight(to item: AVPlayerItem) {
        guard maximumPlaybackHeight > 0 else { return }
        item.preferredMaximumResolution = .zero
        let cap = maximumPlaybackHeight <= 480 ? 3_000_000.0 : 0
        guard cap > 0 else { return }
        let current = item.preferredPeakBitRate
        item.preferredPeakBitRate = current > 0 ? min(current, cap) : cap
    }

    public func setDelegate(delegate: KinescopeVideoPlayerDelegate) {
        self.delegate = delegate
    }

    public func addCustomPlayerOption(with id: AnyHashable, and icon: UIImage) {
        customOptions.append(.custom(id: id, icon: icon))
    }

    public func disableOptions(_ options: [KinescopePlayerOption]) {
        disabledOptions = options
    }
}

// MARK: - Playback control

public extension KinescopeVideoPlayer {

    /// Current playback position in seconds
    var currentTime: TimeInterval {
        let seconds = strategy.player.currentTime().seconds
        return seconds.isFinite ? max(0, seconds) : 0
    }

    /// Duration of video in seconds. For live streams it is the end of seekable range.
    /// `nil` until video is ready to play.
    var duration: TimeInterval? {
        guard let duration = strategy.player.durationSeconds, duration.isFinite, duration > 0 else {
            return nil
        }
        return duration
    }

    /// Current playback speed. `1.0` is natural rate.
    var playbackSpeed: Float {
        playbackRate
    }

    /// Current volume from `0.0` to `1.0`
    var volume: Float {
        strategy.player.volume
    }

    /// Mute or unmute video sound
    var isMuted: Bool {
        get { strategy.player.isMuted }
        set { strategy.player.isMuted = newValue }
    }

    /// `true` if video starts again after it reaches the end
    var isLooped: Bool {
        isLoopEnabled
    }

    /// Move playback to position
    ///
    /// Can be called before video is ready: position will be applied when playback starts.
    /// - parameter seconds: Position from the beginning of video in seconds
    public func seek(to seconds: TimeInterval) {
        let target = max(0, seconds)
        guard strategy.player.isReadyToPlay else {
            pendingStartTime = target
            time = target
            return
        }
        let clamped = duration.map { min($0, target) } ?? target
        time = clamped
        analytic?.send(event: .seek)
        performSeek(to: clamped)
    }

    /// Move playback forward (positive offset) or backward (negative offset)
    ///
    /// - parameter offset: Offset from current position in seconds
    func seek(by offset: TimeInterval) {
        seek(to: currentTime + offset)
    }

}

// MARK: - KinescopePlayerConfigurable

extension KinescopeVideoPlayer: KinescopePlayerConfigurable {

    public func setVolume(_ volume: Float) {
        strategy.player.volume = min(max(volume, 0), 1)
    }

    public func setSpeed(_ speed: Float) {
        guard speed > 0 else {
            if speed == 0 {
                pause()
            }
            return
        }
        apply(rate: speed)
    }

    public func setLoop(enabled: Bool) {
        isLoopEnabled = enabled
        enabled ? strategy.startLooping() : strategy.stopLooping()
    }

}

// MARK: - Private

private extension KinescopeVideoPlayer {

    /// Poster for the picture and the lock screen. A downloaded video uses the copy saved
    /// during download, so it works without the network.
    func posterSource(for video: KinescopeVideo) -> String? {
        if config.localPlaybackURL != nil,
           let local = OfflineVideoStore.posterFileURL(for: video.id),
           FileManager.default.fileExists(atPath: local.path) {
            return local.absoluteString
        }
        return video.poster?.url
    }

    /// Sends request video by id and sets player's item
    func load() {
        // Downloaded video: start from the saved copy of its metadata, no network round trip.
        if config.localPlaybackURL != nil, let cached = OfflineVideoStore.video(for: config.videoId) {
            isLoadingVideo = false
            self.video = cached
            view?.set(preview: posterSource(for: cached))
            view?.overlay?.set(title: cached.title, subtitle: cached.description)
            view?.set(options: makePlayerOptions(from: cached))
            updateChapters()
            delegate?.playerDidLoadVideo(error: nil)
            didPlay()
            return
        }

        guard !isLoadingVideo else {
            return
        }
        isLoadingVideo = true
        let generation = loadGeneration
        view?.startLoader()

        dependencies.inspector.video(
            id: config.videoId,
            drmAuthToken: config.drmAuthToken,
            onSuccess: { [weak self] video in
                guard let self, generation == self.loadGeneration else {
                    return
                }
                self.isLoadingVideo = false
                self.video = video
                self.view?.hidePlaybackError()
                if Self.isAwaitingBroadcast(video) {
                    self.view?.showLiveAwaitingCover()
                    self.view?.announceSnack?.display(startsAt: video.live?.startsAt)
                } else {
                    self.view?.set(preview: self.posterSource(for: video))
                }
                self.view?.overlay?.set(title: video.title, subtitle: video.description)
                self.view?.set(options: self.makePlayerOptions(from: video))
                self.updateChapters()
                self.delegate?.playerDidLoadVideo(error: nil)
                guard self.wantsPlayback else {
                    return
                }
                if video.hlsLink.isEmpty {
                    self.view?.stopLoader()
                    if Self.isBroadcast(video) {
                        self.view?.showLiveAwaitingCover()
                        self.view?.announceSnack?.display(startsAt: video.live?.startsAt)
                    } else {
                        self.view?.displayPlaybackError(KinescopeInspectError.notFound)
                    }
                    return
                }
                self.didPlay()
            },
            onError: { [weak self] error in
                guard let self, generation == self.loadGeneration else {
                    return
                }
                self.isLoadingVideo = false
                Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.network)
                // Downloaded file without saved metadata (or offline): play the file itself.
                if let localURL = self.config.localPlaybackURL {
                    self.playDownloaded(from: localURL)
                    return
                }
                self.view?.stopLoader()
                self.view?.displayPlaybackError(error)
                self.delegate?.playerDidLoadVideo(error: error)
            }
        )
    }

    /// Looped playback replaces its AVQueuePlayer when it binds, so the layer and
    /// the observers have to follow the new instance.
    func installLoopHandoffIfNeeded() {
        guard !didInstallLoopHandoff else {
            return
        }
        didInstallLoopHandoff = true
        guard let looped = strategy as? LoopedPlayingStrategy else {
            return
        }
        looped.onPlayerReplaced = { [weak self] previous, current in
            self?.adoptReplacedPlayer(from: previous, to: current)
        }
    }

    func adoptReplacedPlayer(from previous: AVPlayer, to current: AVPlayer) {
        if let playbackObserver {
            previous.removeTimeObserver(playbackObserver)
            self.playbackObserver = nil
        }
        view?.replacePlayer(current)
        guard view != nil else {
            return
        }
        kvoBag.removeObserver(for: .playerTimeControlStatus)
        kvoBag.removeObserver(for: .playerStatus)
        kvoBag.removeObserver(for: .playerItem)
        kvoBag.removeObserver(for: .playerItemStatus)
        kvoBag.removeObserver(for: .playerItemBufferEmpty)
        kvoBag.removeObserver(for: .playerItemPresentationSize)
        addPlayerTimeControlStatusObserver()
        addPlayerStatusObserver()
        addPlayerItemObserver()
        observePlaybackTime()
    }

    func playDownloaded(from url: URL) {
        Kinescope.shared.logger?.log(message: "Playing downloaded file without metadata",
                                     level: KinescopeLoggerLevel.player)
        view?.stopLoader(withPreview: false)
        select(quality: .downloaded(url: url))
        strategy.play(with: playbackRate)
        delegate?.playerDidPlay()
    }

    func makePlayerOptions(from video: KinescopeVideo) -> [KinescopePlayerOption] {
        var options: [KinescopePlayerOption] = [.airPlay, .settings, .fullscreen, .more]

        if FeatureToggle.assetDownloaderEnabled && video.hasAssets {
            options.insert(.download, at: 1)
        }

        if video.hasAttachments {
            options.insert(.attachments, at: 0)
        }

        if AVPictureInPictureController.isPictureInPictureSupported() {
            options.insert(.pip, at: options.count - 2)
        }

        if video.hasSubtitles {
            options.insert(.subtitles, at: 0)
        }

        if let settingsIndex = options.firstIndex(of: .settings) {
            if !playlist.isEmpty {
                options.insert(.playlist, at: settingsIndex)
            }
            if !Self.isBroadcast(video) && !video.availableChapters.isEmpty {
                options.insert(.chapters, at: settingsIndex)
            }
        }
        options = (customOptions + options).filter { !disabledOptions.contains($0) }
        self.options = options
        return options
    }

    func observePlaybackTime() {
        playbackObserverFactory = PlaybackTimePeriodicObserver(
            period: CMTimeMakeWithSeconds(Constants.periodicIntervalInSeconds,
                                          preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
            playerBody: self,
            secondsPlayed: { [weak self] updatedTime in
                self?.revealIfPictureMoved(to: updatedTime)
                if self?.isPlaying == true {
                    self?.view?.hidePlaybackError()
                }

                guard let self, !isSeeking, !isPreparingSeek else {
                    return
                }

                analyticStorage.sessionInput.incrementWatchedDuration(by: Constants.periodicIntervalInSeconds)

                time = updatedTime
                refreshAutoBadgeFromPlayback()

                if analyticStorage.session.isWatchingMoreThen(threshold: Constants.viewThreshold) {
                    analytic?.sendOnce(event: .view)
                }
                if analyticStorage.session.isWatchingIn(interval: playbackThreshold) {
                    analytic?.send(event: .playback)
                }
                if strategy.player.isBuffering {
                    analytic?.send(event: .buffering)
                }
        })
        playbackObserver = playbackObserverFactory?.provide()
    }

    func removePlaybackTimeObserver() {
        if let timeObserver = playbackObserver {
            strategy.player.removeTimeObserver(timeObserver)
            self.playbackObserver = nil
        }
    }

    func addPlayerStatusObserver() {
        let observerFactory = PlayerStatusObserver(playerBody: self, 
                                                   repeater: $playRepeater)
        kvoBag.addObserver(for: .playerStatus, using: .init(wrappedFactory: observerFactory))
    }
    
    func addPlayerItemObserver() {
        let observerFactory = CurrentItemObserver(playerBody: self, currentItemChanged: {
            [weak self] item in
            self?.kvoBag.removeObserver(for: .playerItemStatus)
            self?.kvoBag.removeObserver(for: .playerItemBufferEmpty)
            self?.kvoBag.removeObserver(for: .playerItemPresentationSize)
            if item != nil {
                self?.addPlayerItemStatusObserver()
                self?.addPlayerItemBufferIsEmptyObserver()
                self?.addPlayerItemPresentationSizeObserver()
            }
        })
        kvoBag.addObserver(for: .playerItem, using: .init(wrappedFactory: observerFactory))
    }
    
    func addPlayerItemBufferIsEmptyObserver() {
        let observerFactory = EmptyBufferObserver(playerBody: self, repeater: $playRepeater)
        kvoBag.addObserver(for: .playerItemBufferEmpty, using: .init(wrappedFactory: observerFactory))
    }

    func addPlayerItemPresentationSizeObserver() {
        let observerFactory = PresentationSizeObserver(playerBody: self) { [weak self] oldSize, newSize in
            guard let self else {
                return
            }
            let measured = Self.playbackDisplayHeight(newSize)
            if isAutomaticQuality {
                guard measured >= 144 else {
                    return
                }
                presentationHeight = matchedPlaybackHeight(raw: measured)
            } else {
                presentationHeight = measured
            }
            view?.controlPanel?.set(settingsBadgeFor: settingsBadgeHeight())
            guard oldSize != .zero, currentQuality == L10n.Player.auto else {
                return
            }
            analytic?.send(event: .autoqualitychanged)
        }
        kvoBag.addObserver(for: .playerItemPresentationSize, using: .init(wrappedFactory: observerFactory))
    }

    func addPlayerItemStatusObserver() {
        let observerFactory = CurrentItemStatusObserver(playerBody: self, 
                                                        repeater: $playRepeater,
                                                        readyToPlayReceived: { [weak self] in
            guard let self, let video else {
                return
            }
            let seconds = pendingStartTime ?? savedTime.seconds
            pendingStartTime = nil
            savedTime = .zero
            if Self.isBroadcast(video), !isAwaitingLiveStart, seconds <= 0,
               let edge = strategy.player.durationSeconds, edge > 1 {
                time = edge
                performSeek(to: edge)
            } else if seconds > .zero {
                time = seconds
                performSeek(to: seconds)
            }
            isLive = Self.isBroadcast(video) && strategy.player.isReadyToPlay
            self.$playRepeater.reset()
            updateNowPlaying()
            updateChapters()
            loadAudioTracks()
            // Android drops the live cover on STATE_READY. Waiting for the picture
            // to drift kept the stub up through the seek to the live edge.
            if Self.isBroadcast(video), !isAwaitingLiveStart {
                presentVideo()
            }
        })
        kvoBag.addObserver(for: .playerItemStatus, using: .init(wrappedFactory: observerFactory))
    }

    func addPlayerTimeControlStatusObserver() {
        let observerFactory = TimeControlStatusObserver(playerBody: self,
                                                        timeControlStatusChanged: { [weak self] status in
            self?.handle(timeControlStatus: status)
        })
        kvoBag.addObserver(for: .playerTimeControlStatus, using: .init(wrappedFactory: observerFactory))
    }

    func handle(timeControlStatus status: AVPlayer.TimeControlStatus) {
        isPlaying = status == .playing
        if status == .playing {
            applyMeasuredAutoHeight()
        }
        if status == .playing, !hasPresentedVideo {
            if Self.isBroadcast(video), !isAwaitingLiveStart {
                presentVideo()
            } else if revealsOnPlay {
                presentVideo()
            } else if revealAnchor == nil {
                let seconds = strategy.player.currentTime().seconds
                revealAnchor = seconds.isFinite ? seconds : 0
                // A waiting live stream reports `.playing` on a black frame. Keep the cover
                // until the picture actually moves, instead of dropping it on a short timer.
                if !Self.isBroadcast(video) {
                    scheduleRevealFallback()
                }
            }
        }

        switch status {
        case .waitingToPlayAtSpecifiedRate:
            // Loading failures before item is ready are retried by `playRepeater`.
            if strategy.player.isReadyToPlay && !isAwaitingLiveStart {
                stallWatchdog.bufferingStarted()
            }
        case .playing, .paused:
            stallWatchdog.reset()
        @unknown default:
            stallWatchdog.reset()
        }

        updateNowPlaying()
    }

    /// Keeps the poster up until playback time actually moves, so the still
    /// preview frame never shows between the poster and the video.
    func revealIfPictureMoved(to time: TimeInterval) {
        guard !hasPresentedVideo, isPlaying, !isSeeking, time.isFinite, let anchor = revealAnchor else {
            return
        }
        guard time - anchor >= 0.12 else {
            return
        }
        presentVideo()
    }

    func scheduleRevealFallback() {
        revealFallback?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self, self.isPlaying, !self.hasPresentedVideo else {
                return
            }
            self.presentVideo()
        }
        revealFallback = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: work)
    }

    /// Shows the picture as soon as playback starts. The feed uses this so a short does not sit on the poster.
    public func revealPictureOnPlay() {
        revealsOnPlay = true
        if isPlaying, !hasPresentedVideo {
            presentVideo()
        }
    }

    func presentVideo() {
        revealFallback?.cancel()
        revealFallback = nil
        hasPresentedVideo = true
        view?.revealVideo()
    }

    func handlePlaybackStall() {
        Kinescope.shared.logger?.log(message: "playback stalled: no progress while buffering, pausing",
                                     level: KinescopeLoggerLevel.player)
        pause()
        view?.stopLoader(withPreview: strategy.player.isReadyToPlay)
        view?.displayPlaybackError(PlaybackStallError.stalled)
        delegate?.playerDidStall()
    }

    func addNotofications() {
        notificationsBag.addObserver(for: .appWillEnterForeground,
                                     using: .init(selector: #selector(appWillEnterForeground)))
        notificationsBag.addObserver(for: .appDidEnterBackground,
                                     using: .init(selector: #selector(appDidEnterBackground)))
        notificationsBag.addObserver(for: .deviceOrientationChanged,
                                     using: .init(selector: #selector(changeOrientation)))
        notificationsBag.addObserver(for: .itemDidPlayToEnd,
                                     using: .init(selector: #selector(itemDidPlayToEnd)))
        notificationsBag.addObserver(for: .itemFailedToPlayToEndTime,
                                     using: .init(selector: #selector(itemFailedToPlayeToEndTime)))
    }
    
    func configureAnalytic() {
        analyticStorage.playbackInput.setPlayer(strategy.player)
        analyticStorage.playbackInput.setQualityProvider(self)
        analyticStorage.playbackInput.setFullscreenStateProvider(self)
    }

    func performSeek(to seconds: TimeInterval) {
        let duration = strategy.player.durationSeconds ?? .zero
        // end of timeline reached
        if seconds >= duration {
            if strategy.player.hasFiniteDuration && !Self.isBroadcast(video) {
                // stop playing vod
                pause()
            } else {
                // continue live stream
                isLive = true
            }
        } else {
            // seek backward, so it is not live anymore
            isLive = false
        }
        self.isSeeking = true
        let time = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

        Kinescope.shared.logger?.log(message: "timeline changed to \(seconds) seconds",
                                     level: KinescopeLoggerLevel.player)
        delegate?.player(didSeekTo: seconds)

        strategy.player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] finished in
            guard let self else { return }
            self.isSeeking = false
            if !self.hasPresentedVideo {
                let seconds = self.strategy.player.currentTime().seconds
                self.revealAnchor = seconds.isFinite ? seconds : 0
            }
            if finished, self.wantsPlayback, self.strategy.player.rate == 0 {
                self.strategy.play(with: self.playbackRate)
            }
            self.updateNowPlaying()
        }
    }

    func apply(rate: Float) {
        playbackRate = rate
        if strategy.player.rate != 0 {
            strategy.player.rate = rate
        }
        analytic?.send(event: .rate)
        updateNowPlaying()
    }

    func updateNowPlaying() {
        guard isNowPlayingEnabled else {
            return
        }
        nowPlaying.update(.init(
            title: video?.title,
            subtitle: video?.description,
            duration: duration,
            elapsed: currentTime,
            rate: isPlaying ? playbackRate : 0,
            isLive: video?.type == .live
        ))
    }

    @objc
    func changeOrientation() {
        guard let view = view,
              view.canBeFullScreen else {
            return
        }

        guard !KinescopeFullscreenViewController.isTransitioning else {
            return
        }
        let isFullScreen = KinescopeFullscreenViewController.isPresented
        let interfaceLandscape = view.window?.windowScene?.interfaceOrientation.isLandscape ?? false
        let device = UIDevice.current.orientation

        // A landscape reading means the phone really turned. Only then may a later
        // portrait reading leave fullscreen. Seek taps also post this notification,
        // often with a portrait value, while the video is still landscape.
        if device.isLandscape {
            exitFullscreenOnPortrait = isFullScreen || interfaceLandscape
            portraitExit?.cancel()
            portraitExit = nil
        }

        // Device orientation can report landscape for a moment while the screen
        // is still portrait. Fullscreen follows the interface, so opening a
        // video does not flash a landscape player.
        if interfaceLandscape && device.isLandscape && !isFullScreen {
            exitFullscreenOnPortrait = true
            didPresentFullscreen(from: view)
            return
        }

        guard isFullScreen, device.isPortrait, exitFullscreenOnPortrait else {
            return
        }
        guard CACurrentMediaTime() >= ignorePortraitExitUntil else {
            return
        }

        portraitExit?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self, let view = self.view else {
                return
            }
            guard UIDevice.current.orientation.isPortrait,
                  self.exitFullscreenOnPortrait,
                  CACurrentMediaTime() >= self.ignorePortraitExitUntil,
                  KinescopeFullscreenViewController.isPresented,
                  !KinescopeFullscreenViewController.isTransitioning else {
                return
            }
            self.didPresentFullscreen(from: view)
        }
        portraitExit = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: work)
    }

    func holdPortraitExitForSeek() {
        ignorePortraitExitUntil = CACurrentMediaTime() + 0.7
        portraitExit?.cancel()
        portraitExit = nil
    }

    @objc func appWillEnterForeground() {
        if !(view?.pipController?.isPictureInPictureActive ?? false) {
            if view?.playerView.player !== strategy.player {
                view?.playerView.player = strategy.player
            }
            if hasPresentedVideo {
                view?.revealVideo()
            }
        }
        pausedForBackground = false
    }

    @objc func appDidEnterBackground() {
        let pictureInPicture = view?.pipController?.isPictureInPictureActive ?? false
        if pictureInPicture {
            return
        }
        // Background audio stays only for Lock Screen / Control Center playback.
        // Otherwise minimizing the app pauses, same as Android with background playback off.
        if !isNowPlayingEnabled, isPlaying {
            pausedForBackground = true
            pause()
        }
    }

    @objc func itemDidPlayToEnd(_ notification: Notification) {
        // Notification is posted for items of all players, handle only own one.
        guard let item = notification.object as? AVPlayerItem,
              strategy.isLooping || item === strategy.player.currentItem else {
            return
        }

        analytic?.send(event: .end)
        delegate?.playerDidFinishPlaying()

        guard isLoopEnabled, !strategy.isLooping else {
            if !strategy.isLooping {
                view?.showReplay()
            }
            return
        }

        analytic?.send(event: .replay)
        if strategy.player.currentItem == nil {
            play()
        } else {
            time = .zero
            performSeek(to: .zero)
            strategy.play(with: playbackRate)
        }
    }

    @objc func itemFailedToPlayeToEndTime(_ notification: Notification) {
        let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error
        Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.player)
    }

    func restoreView() {
        view?.suppressControlReveal = true
        if view?.holdsControlReveal != true {
            view?.revealControls(autoHide: isPlaying)
        }
        wantsPlayback ? play() : pause()
        view?.suppressControlReveal = false
    }

    func updateTimeline() {
        cachedDuration = strategy.player.durationSeconds ?? .zero
        view?.playbackTime = time

        if let pending = pendingSeekPosition, cachedDuration > 0 {
            time = min(cachedDuration, pending * cachedDuration)
            pendingSeekPosition = nil
            performSeek(to: time)
        }

        let position: CGFloat = {
            guard !strategy.player.hasFiniteDuration,
                    !isLive else {
                return CGFloat(time / cachedDuration)
            }

            return CGFloat(time / $cachedDuration)
        }()

        if !position.isNaN {
            view?.controlPanel?.setTimeline(to: CGFloat(position))
        } else {
            view?.controlPanel?.setTimeline(to: 0)
        }
        if !time.isNaN {
            let duration = strategy.player.hasFiniteDuration ? cachedDuration : nil
            view?.controlPanel?.setIndicator(to: time, duration: duration)
        }
        view?.showSubtitle(SubtitleCueParser.text(at: time, in: subtitleCues))
    }

    func updateLiveIndicator() {
        if Self.isBroadcast(video) {
            view?.controlPanel?.set(live: isLive)
        } else {
            view?.controlPanel?.set(live: nil)
        }
    }

}

// MARK: - KinescopePlayerViewDelegate

extension KinescopeVideoPlayer: KinescopePlayerViewDelegate {

    func didPlay() {
        let duration = strategy.player.durationSeconds ?? .zero
        // Playing from start should not be available for live streams
        if duration > 0 && duration - time < 0.5 && strategy.player.hasFiniteDuration {
            time = .zero
            performSeek(to: time)
            analytic?.send(event: .replay)
        }
        
        analytic?.send(event: .play)

        self.$playRepeater.reset()
        self.play()
    }

    func didPause() {
        analytic?.send(event: .pause)
        self.pause()
    }

    func didSeek(to position: Double) {
        holdPortraitExitForSeek()
        isPreparingSeek = true

        Kinescope.shared.logger?.log(message: "timeline seeked to \(position)",
                                     level: KinescopeLoggerLevel.player)

        if let duration = strategy.player.durationSeconds, duration > 0 {
            time = min(duration, position * duration)
            pendingSeekPosition = nil
        } else {
            pendingSeekPosition = position
        }

        delegate?.player(timelinePositionMovedTo: position)
    }

    func didConfirmSeek() {
        isPreparingSeek = false
        if let pending = pendingSeekPosition, let duration = strategy.player.durationSeconds, duration > 0 {
            time = min(duration, pending * duration)
            pendingSeekPosition = nil
        }
        Kinescope.shared.logger?.log(message: "timeline change to time: \(time) confirmed",
                                     level: KinescopeLoggerLevel.player)
        analytic?.send(event: .seek)
        performSeek(to: time)
    }

    func didTouchVideo() {
        holdPortraitExitForSeek()
    }

    func didFastForward() {
        holdPortraitExitForSeek()
        guard let duration = strategy.player.durationSeconds else {
            return
        }

        Kinescope.shared.logger?.log(message: "fast forward +\(FastSeek.step)s", level: KinescopeLoggerLevel.player)

        time = min(duration, time + FastSeek.step)
        analytic?.send(event: .seek)
        performSeek(to: time)

        delegate?.player(didFastForwardTo: time)
    }

    func didFastBackward() {
        holdPortraitExitForSeek()
        Kinescope.shared.logger?.log(message: "fast backward -\(FastSeek.step)s", level: KinescopeLoggerLevel.player)

        time = max(time - FastSeek.step, .zero)
        analytic?.send(event: .seek)
        performSeek(to: time)

        delegate?.player(didFastBackwardTo: time)
    }

    func didPresentFullscreen(from view: KinescopePlayerView) {
        guard !KinescopeFullscreenViewController.isTransitioning else {
            return
        }
        if KinescopeFullscreenViewController.isPresented {
            exitFullscreenOnPortrait = false
            portraitExit?.cancel()
            portraitExit = nil
            isOverlayed = view.overlay?.isSelected ?? false
            detach(view: view)
            
            isFullScreenModeActive = false
            analytic?.send(event: .exitfullscreen)

            KinescopeFullscreenViewController.dismiss { [weak self] in
                guard
                    let self,
                    let miniView = self.miniView
                else {
                    return
                }

                self.attach(view: miniView)
                self.restoreView()
            }
        } else {
            miniView = view
            isOverlayed = view.overlay?.isSelected ?? false

            guard let video else {
                return
            }

            isFullScreenModeActive = true
            analytic?.send(event: .enterfullscreen)

            KinescopeFullscreenViewController.present(player: self,
                                                      video: video,
                                                      from: view,
                                                      with: view.config) { [weak self] in
                guard let self else {
                    return
                }

                let host = self.view ?? view
                host.overlay?.set(title: video.title, subtitle: video.description)
                host.stopLoader(withPreview: strategy.player.isReadyToPlay)
                restoreView()
            }
        }
    }

    func didShowAttachments() -> [KinescopeVideoAdditionalMaterial]? {
        return video?.attachments
    }

    func didSelect(rate: Float) {
        apply(rate: rate)
    }

    func didSelect(quality: String) {
        guard let video = video else {
            Kinescope.shared.logger?.log(message: "Can't find video",
                                         level: KinescopeLoggerLevel.player)
            return
        }

        let videoQuality: KinescopeVideoQuality
        if let asset = video.firstQuality(by: quality) {
            if let path = dependencies.assetDownloader.getLocation(by: video.id + asset.name) {
                videoQuality = .downloaded(url: path)
            } else {
                videoQuality = .exact(asset: asset)
            }
        } else {
            videoQuality = .auto(hlsLink: video.hlsLink)
        }

        currentQuality = quality
        view?.controlPanel?.set(settingsBadgeFor: settingsBadgeHeight())

        analytic?.send(event: .qualitychanged)

        select(quality: videoQuality)
        if isAutomaticQuality {
            applyMeasuredAutoHeight()
        }

        Kinescope.shared.logger?.log(message: "Select quality: \(quality)",
                                     level: KinescopeLoggerLevel.player)

        delegate?.player(changedQualityTo: quality)
    }

    func didSelectAttachment(with id: String) {
        guard let attachment = video?.firstAttachment(by: id) else {
            return
        }
        dependencies.attachmentDownloader.enqueueDownload(attachment: attachment)
        Kinescope.shared.logger?.log(message: "Start downloading attachment: \(attachment.title)",
                                     level: KinescopeLoggerLevel.player)
    }

    func didSelectDownloadAll(for title: String) {
        guard let video else {
            return
        }

        switch SideMenu.DescriptionTitle.getType(by: title) {
        case .attachments:
            video.attachments?.forEach {
                dependencies.attachmentDownloader.enqueueDownload(attachment: $0)
                Kinescope.shared.logger?.log(message: "Start downloading attachment: \($0.title)",
                                             level: KinescopeLoggerLevel.player)
            }
        case .download:
            video.downloadableAssets.forEach {
                dependencies.assetDownloader.enqueueDownload(video: video, asset: $0)
                Kinescope.shared.logger?.log(message: "Start downloading asset: \($0.name) - \(video.id)",
                                             level: KinescopeLoggerLevel.player)
            }
        case .subtitleSearch, .chapters, .none:
            break
        }
    }

    func didSelect(subtitles: String) {
        guard let video else {
            Kinescope.shared.logger?.log(message: "Can't find video",
                                         level: KinescopeLoggerLevel.player)
            return
        }

        if let item = strategy.player.currentItem,
           let group = item.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) {
            item.select(nil, in: group)
        }

        subtitleTask?.cancel()
        subtitleCues = []
        view?.subtitleCues = []
        view?.showSubtitle(nil)

        guard let selected = video.firstSubtitle(by: subtitles),
              let url = URL(string: selected.url) else {
            currentSubtitles = nil
            view?.controlPanel?.set(subtitleOn: false)
            return
        }

        currentSubtitles = subtitles
        view?.controlPanel?.set(subtitleOn: true)
        Kinescope.shared.logger?.log(message: "Select subtitles: \(subtitles)",
                                     level: KinescopeLoggerLevel.player)

        subtitleTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            let cues = data.flatMap { SubtitleCueParser.parse(String(decoding: $0, as: UTF8.self)) } ?? []
            DispatchQueue.main.async {
                guard let self, self.currentSubtitles == subtitles else {
                    return
                }
                if let error {
                    Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.network)
                }
                self.subtitleCues = cues
                self.view?.subtitleCues = cues
                self.view?.showSubtitle(SubtitleCueParser.text(at: self.time, in: cues))
            }
        }
        subtitleTask?.resume()
    }

    func didSelect(option: AnyHashable, optionView: UIView) {
        delegate?.player(didSelectCustomOptionWith: option, anchoredAt: optionView)
    }

    func didSelect(audioTrack index: Int) {
        selectAudioTrack(at: index)
    }

    func didSelect(playlistItem: KinescopePlaylistItem) {
        delegate?.player(didSelectPlaylistItem: playlistItem)
    }

    func didSeekToLive() {
        guard Self.isBroadcast(video) else {
            return
        }
        let end = strategy.player.durationSeconds ?? 0
        guard end > 0 else {
            return
        }
        Kinescope.shared.logger?.log(message: "seek to live edge", level: KinescopeLoggerLevel.player)
        time = end
        performSeek(to: end)
        isLive = true
        if !isPlaying {
            play()
        }
    }

    func didSeek(toTime seconds: TimeInterval) {
        let duration = strategy.player.durationSeconds ?? 0
        let target = duration > 0 ? min(max(0, seconds), duration) : max(0, seconds)
        time = target
        performSeek(to: target)
    }

    func didUpdate(subtitleStyle: SubtitleStyle) {
        self.subtitleStyle = subtitleStyle
        view?.subtitleStyle = subtitleStyle
        view?.subtitleOverlay?.apply(subtitleStyle)
    }

}

// MARK: - Phase 2 chrome

public extension KinescopeVideoPlayer {

    /// Titles of available audio tracks of current video. Empty if video has single track.
    var audioTracks: [String] {
        audioOptions.count > 1 ? audioTrackTitles : []
    }

    /// Select audio track by index from `audioTracks`.
    func selectAudioTrack(at index: Int) {
        guard let group = audioGroup,
              audioOptions.indices.contains(index),
              let item = strategy.player.currentItem else {
            return
        }
        item.select(audioOptions[index], in: group)
        view?.selectedAudioTrack = index
        Kinescope.shared.logger?.log(message: "Select audio track: \(audioTrackTitles[index])",
                                     level: KinescopeLoggerLevel.player)
    }

    /// Show playlist button and menu. Selection is reported via
    /// `KinescopeVideoPlayerDelegate.player(didSelectPlaylistItem:)`, host app loads chosen video.
    ///
    /// - parameter items: Playlist items. Empty array hides playlist button.
    /// - parameter currentItemId: Id of item which is playing now.
    func setPlaylist(_ items: [KinescopePlaylistItem], currentItemId: String?) {
        playlist = items
        currentPlaylistItemId = currentItemId
        view?.playlist = items
        view?.currentPlaylistItemId = currentItemId
        if let video {
            view?.set(options: makePlayerOptions(from: video))
        }
        // Build the sheet before the first tap, so opening it does not hitch.
        DispatchQueue.main.async { [weak self] in
            self?.view?.warmPlaylistSheet()
        }
    }

}

extension KinescopeVideoPlayer {

    var isAutomaticQuality: Bool {
        let quality = currentQuality.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalized = quality.lowercased()
        return normalized.isEmpty || normalized == "auto" || quality == L10n.Player.auto
    }

    /// While Auto is on, follow the rendition that is actually decoding.
    ///
    /// Reading the access log is a synchronous call to the media server. The periodic observer ticks
    /// 100 times a second, so the badge refreshes once a second, and only when a gear badge exists.
    func refreshAutoBadgeFromPlayback() {
        guard isAutomaticQuality, view?.controlPanel != nil else {
            return
        }
        let now = CACurrentMediaTime()
        guard now - lastAutoHeightCheck >= 1 else {
            return
        }
        lastAutoHeightCheck = now
        applyMeasuredAutoHeight()
    }

    func applyMeasuredAutoHeight() {
        guard isAutomaticQuality, let item = strategy.player.currentItem else {
            return
        }
        let sizeHeight = Self.playbackDisplayHeight(item.presentationSize)
        let bitrate = item.accessLog()?.events.last?.indicatedBitrate ?? 0
        let fromSize = sizeHeight >= 144 ? matchedPlaybackHeight(raw: sizeHeight) : 0
        let fromBitrate = bitrate > 0 ? matchedPlaybackHeight(raw: height(forBitrate: bitrate)) : 0
        let height = max(fromSize, fromBitrate)
        guard height > 0, abs(height - presentationHeight) > 1 else {
            return
        }
        presentationHeight = height
        view?.controlPanel?.set(settingsBadgeFor: height)
    }

    /// Snap a decoded frame to the nearest listed rendition, so 1072 still counts as 1080.
    func matchedPlaybackHeight(raw: CGFloat) -> CGFloat {
        guard raw > 0 else {
            return 0
        }
        let known = availableAssets.map { CGFloat($0.height) }.filter { $0 > 0 }
        guard let nearest = known.min(by: { abs($0 - raw) < abs($1 - raw) }) else {
            return raw
        }
        if abs(nearest - raw) <= max(96, raw * 0.2) {
            return nearest
        }
        return raw
    }

    func height(forBitrate bitrate: Double) -> CGFloat {
        let ladder: [(CGFloat, Double)] = [
            (240, 700_000),
            (360, 1_500_000),
            (480, 2_000_000),
            (720, 4_000_000),
            (1080, 6_000_000),
            (1440, 10_000_000),
            (2160, 16_000_000)
        ]
        var chosen = ladder[0].0
        for rung in ladder where bitrate >= rung.1 * 0.75 {
            chosen = rung.0
        }
        return chosen
    }

    /// Gear badge follows the locked rendition. Auto uses the frame that is actually playing.
    func settingsBadgeHeight() -> CGFloat {
        let quality = currentQuality.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalized = quality.lowercased()
        if normalized.isEmpty || normalized == "auto" || quality == L10n.Player.auto {
            return presentationHeight
        }
        if normalized == "audio" || normalized == "audio_only" || normalized == "audio-only" {
            return 0
        }
        if let asset = video?.firstQuality(by: quality), asset.height > 0 {
            return CGFloat(asset.height)
        }
        let digits = quality.filter(\.isNumber)
        if let value = Int(digits), value > 0 {
            return CGFloat(value)
        }
        return 0
    }

    /// Shorter side, so a portrait 720×1280 frame stays 720 and does not pick up an HD badge.
    static func playbackDisplayHeight(_ size: CGSize) -> CGFloat {
        let width = abs(size.width)
        let height = abs(size.height)
        if width > 0, height > 0 {
            return min(width, height)
        }
        return max(width, height)
    }

    func applyChromeState(to view: KinescopePlayerView) {
        view.playlist = playlist
        view.currentPlaylistItemId = currentPlaylistItemId
        view.audioTracks = audioTracks
        view.selectedAudioTrack = selectedAudioTrackIndex
        view.controlPanel?.set(settingsBadgeFor: settingsBadgeHeight())
        view.subtitleCues = subtitleCues
        view.subtitleStyle = subtitleStyle
        view.subtitleOverlay?.apply(subtitleStyle)
        updateChapters()
    }

    func updateChapters() {
        let chapters = video?.availableChapters ?? []
        let duration: TimeInterval = {
            if let duration = video?.duration, duration > 0 {
                return duration
            }
            return cachedDuration.isFinite ? cachedDuration : 0
        }()
        view?.chapters = chapters
        view?.chaptersDuration = duration
        view?.controlPanel?.set(chapters: video?.type == .live ? [] : chapters, duration: duration)
    }

    var selectedAudioTrackIndex: Int? {
        guard let group = audioGroup,
              let selected = strategy.player.currentItem?.currentMediaSelection.selectedMediaOption(in: group) else {
            return nil
        }
        return audioOptions.firstIndex(of: selected)
    }

    func loadAudioTracks() {
        guard let item = strategy.player.currentItem else {
            return
        }
        item.asset.loadMediaSelectionGroup(for: .audible) { [weak self] group, _ in
            DispatchQueue.main.async {
                guard let self else {
                    return
                }
                self.audioGroup = group
                self.audioOptions = group?.options ?? []
                self.audioTrackTitles = Self.makeAudioTitles(for: self.audioOptions)
                self.view?.audioTracks = self.audioTracks
                self.view?.selectedAudioTrack = self.selectedAudioTrackIndex
            }
        }
    }

    static func makeAudioTitles(for options: [AVMediaSelectionOption]) -> [String] {
        let names = options.enumerated().map { index, option -> String in
            let name = option.displayName.trimmingCharacters(in: .whitespacesAndNewlines)
            return name.isEmpty ? L10n.Player.audioTrack(index + 1) : name
        }
        var counters: [String: Int] = [:]
        return names.map { name in
            guard names.filter({ $0 == name }).count > 1 else {
                return name
            }
            counters[name, default: 0] += 1
            return "\(name) · \(counters[name] ?? 1)"
        }
    }

}

// MARK: - Errors

private enum PlaybackStallError: LocalizedError {
    case stalled

    var errorDescription: String? {
        L10n.Player.playbackStalled
    }
}
