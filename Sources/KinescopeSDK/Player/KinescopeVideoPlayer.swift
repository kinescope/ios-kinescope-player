import AVFoundation
import AVKit
import UIKit
// swiftlint:disable file_length

/// KinescopePlayer implementation
public class KinescopeVideoPlayer: NSObject, KinescopePlayer {

    // MARK: - Private Properties

    private let dependencies: KinescopePlayerDependencies
    private lazy var strategy: PlayingStrategy = {
        dependencies.provide(for: config)
    }()
    private let callObserver = CallObserver()
    private lazy var innerEventsHandler: InnerEventsProtoHandler = {
        let service = AnalyticsNetworkService(transport: Transport(), config: Kinescope.shared.config)
        let handler = InnerEventsProtoHandler(service: service)
        handler.setupPlayer()
        handler.setupDevice()
        handler.setSessionId()
        handler.setPlayback(rate: 1)
        handler.setPlayback(isMuted: false)
        return handler
    }()

    private weak var view: KinescopePlayerView?

    private var timeObserver: Any?
    private var playerStatusObserver: NSKeyValueObservation?
    private var itemStatusObserver: NSKeyValueObservation?
    private var timeControlStatusObserver: NSKeyValueObservation?
    private var tracksObserver: NSKeyValueObservation?

    private var isSeeking = false
    private var isPreparingSeek = false
    private var isManualQuality = false
    private var currentQuality = "" {
        didSet {
            innerEventsHandler.setPlayback(quality: currentQuality)
        }
    }
    private var currentSpeed = KinescopePlayerSpeed.normal {
        didSet {
            innerEventsHandler.setPlayback(rate: currentSpeed.rawValue)
        }
    }
    private var currentSutitle: KinescopeVideoSubtitle?
    private var currentAudio: String?
    private var isOverlayed = false
    private var savedTime: CMTime = .zero
    private var loadingDebouncer = Debouncer(timeInterval: 0.1)
    private var pauseDebouncer = Debouncer(timeInterval: 0.05)
    private var airPlayDebouncer = Debouncer(timeInterval: 0.5)
    private weak var miniView: KinescopePlayerView?
    private var video: KinescopeVideo? {
        didSet {
            if let video = video {
                innerEventsHandler.setupVideo(video)
            }
        }
    }
    private let config: KinescopePlayerConfig
    private var options = [KinescopePlayerOption]()

    private var textStyleRules: [AVTextStyleRule]? {
        let pos = kCMTextMarkupAttribute_OrthogonalLinePositionPercentageRelativeToWritingDirection
        guard
            let rule = AVTextStyleRule(
                textMarkupAttributes: [
                    pos as String: 95.0,
                    kCMTextMarkupAttribute_RelativeFontSize as String: 100.0
                ]
            )
        else {
            return nil
        }

        return [rule]
    }
    private lazy var playbackManager: PlaybackManager? = {
        if let duration = video?.duration, duration.isNormal {
            let manager = PlaybackManager(duration: Int(duration), viewSeconds: 5)
            manager.delegate = self
            return manager
        }
        return nil
    }()

    // MARK: - State

    private var time: TimeInterval = 0 {
        willSet {
            let duration = strategy.player.currentItem?.duration.seconds ?? .zero
            isAtEnd = newValue >= duration
            view?.overlay?.isAtBeginning = newValue == 0
        }
        didSet {
            updateTimeline()
            if time.isNormal {
                innerEventsHandler.setPlayback(currentPosition: Int(time))
            }
        }
    }

    private var isPlaying = false {
        didSet {
            updateViewState()
        }
    }
    private var isAtEnd = false {
        didSet {
            updateViewState()
            if isAtEnd {
                innerEventsHandler.end()
                dependencies.eventsCenter.post(event: .end, userInfo: nil)
            }
            view?.overlay?.isAtEnd = isAtEnd
        }
    }

    private var isError = false {
        didSet {
            updateViewState()
        }
    }

    private var isLoading = false {
        didSet {
            updateViewState()
        }
    }

    // MARK: - Lifecycle

    init(config: KinescopePlayerConfig, dependencies: KinescopePlayerDependencies) {
        self.dependencies = dependencies
        self.config = config
        super.init()
        addNotofications()
        callObserver.delegate = self
    }

    deinit {
        self.removePlaybackTimeObserver()
        self.removePlayerItemStatusObserver()
        self.removePlayerTimeControlStatusObserver()
        self.removePlayerStatusObserver()
        self.removeTracksObserver()

        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - KinescopePlayer

    public weak var pipDelegate: AVPictureInPictureControllerDelegate? {
        didSet {
            view?.pipController?.delegate = pipDelegate
        }
    }
    public weak var delegate: KinescopeVideoPlayerDelegate?

    public required convenience init(config: KinescopePlayerConfig) {
        self.init(config: config, dependencies: KinescopeVideoPlayerDependencies())
    }

    public func setVideo(_ video: KinescopeVideo) {
        self.video = video
        if let quality = getCurrentQuality() {
            select(quality: quality)
        }
        view?.set(title: video.title, subtitle: video.description)
        view?.set(options: makePlayerOptions(from: video) )
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.view?.controlPanel?.hideTimeline(false)
            self.view?.controlPanel?.setTimeline(to: 0)
        }
        loadManifest()
    }

    public func play() {
        if video != nil {
            self.strategy.play()
            self.strategy.player.rate = currentSpeed.rawValue
            self.delegate?.playerDidPlay()
        } else {
            view?.state = .initialLoading
            self.load()
        }
        innerEventsHandler.play()
        dependencies.eventsCenter.post(event: .play, userInfo: nil)
    }

    public func pause() {
        self.strategy.pause()
        self.delegate?.playerDidPause()
        innerEventsHandler.pause()
        dependencies.eventsCenter.post(event: .pause, userInfo: nil)
    }

    public func stop() {
        self.strategy.pause()
        self.strategy.unbind()
        self.removeTracksObserver()
        self.delegate?.playerDidStop()
    }

    public func attach(view: KinescopePlayerView) {
        view.playerView.player = self.strategy.player
        view.delegate = self
        self.view = view
        view.set(options: options)
        view.pipController?.delegate = pipDelegate
        updateTimeline()
        observePlaybackTime()
        addPlayerTimeControlStatusObserver()
        addPlayerStatusObserver()
        innerEventsHandler.setSession(viewID: view.uuid)
        innerEventsHandler.setPlayback(isFullscreen: (view.superview ?? UIViewController()) is KinescopeFullscreenViewController)
    }

    public func detach(view: KinescopePlayerView) {
        view.playerView.player = nil
        self.view = nil
        view.delegate = nil

        removePlaybackTimeObserver()
        removePlayerTimeControlStatusObserver()
        removePlayerStatusObserver()
    }

    public func select(quality: KinescopeVideoQuality) {
        strategy.player.rate = 0
        guard let item = quality.item else {
            // Log here critical error
            return
        }

        isManualQuality = !quality.isAuto
        innerEventsHandler.setSession(type: quality.isOnline ? .online : .offline)

        savedTime = strategy.player.currentTime()

        removeTracksObserver()
        removePlayerItemStatusObserver()

        strategy.bind(item: item)

        addPlayerItemStatusObserver()
        addTracksObserver()

        innerEventsHandler.qualitychanged()
        dependencies.eventsCenter.post(event: .qualitychanged, userInfo: nil)
    }

}

// MARK: - KinescopePlayerConfigurable

extension KinescopeVideoPlayer: KinescopePlayerConfigurable {

    public func set(speed: KinescopePlayerSpeed) {
        self.currentSpeed = speed
        strategy.player.rate = speed.rawValue
        view?.change(speed: currentSpeed.toString())
    }

    public func set(muted: Bool) {
        strategy.player.isMuted = muted
        innerEventsHandler.setPlayback(isMuted: muted)
    }

}

// MARK: - Private

private extension KinescopeVideoPlayer {

    /// Sends request video by id and sets player's item
    func load() {
        view?.controlPanel?.hideTimeline(true)
        dependencies.inspector.video(
            id: config.videoId,
            onSuccess: { [weak self] video in
                self?.setVideo(video)
                self?.delegate?.playerDidLoadVideo(error: nil)
                self?.play()
                self?.isError = false
            },
            onError: { [weak self] error in
                self?.isError = true
                self?.delegate?.playerDidLoadVideo(error: error)
                Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.network)
            }
        )
    }

    func makePlayerOptions(from video: KinescopeVideo) -> [KinescopePlayerOption] {
        var options: [KinescopePlayerOption] = [.settings, .fullscreen, .more]

        if #available(iOS 12.3, *) {
            options.insert(.airPlay, at: 0)
        }

        if !video.downloadableAssets.isEmpty {
            options.insert(.download, at: 1)
        }

        if !video.additionalMaterials.isEmpty {
            options.insert(.attachments, at: 0)
        }

        if AVPictureInPictureController.isPictureInPictureSupported() {
            options.insert(.pip, at: options.count - 2)
        }

        if !video.subtitles.isEmpty {
            options.insert(.subtitles, at: 0)
        }

        self.options = options
        return options
    }

    func observePlaybackTime() {
        guard view?.controlPanel != nil else {
            return
        }

        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let period = CMTimeMakeWithSeconds(0.01, preferredTimescale: timeScale)

        timeObserver = strategy.player.addPeriodicTimeObserver(forInterval: period,
                                                               queue: .main) { [weak self] time in
            guard let self = self else {
                return
            }

            /// Does not make sense without control panel and curremtItem
            guard let controlPanel = self.view?.controlPanel,
                  let currentItem = self.strategy.player.currentItem else {
                return
            }

            let duration = currentItem.duration.seconds

            if !self.isSeeking, !self.isPreparingSeek {
                self.time = min(duration, time.seconds)
                self.playbackManager?.register(second: Int(time.seconds))
            }

            Kinescope.shared.logger?.log(message: "playback position changed to \(time) seconds", level: KinescopeLoggerLevel.player)
            self.delegate?.player(playbackPositionMovedTo: time.seconds)

            // Preload observation

            let buferredTime = currentItem.loadedTimeRanges.first?.timeRangeValue.end.seconds ?? 0
            Kinescope.shared.logger?.log(message: "playback buffered \(buferredTime) seconds", level: KinescopeLoggerLevel.player)
            self.delegate?.player(playbackBufferMovedTo: time.seconds)

            let bufferProgress = CGFloat(buferredTime / duration)

            if !bufferProgress.isNaN {
                controlPanel.setBufferred(progress: bufferProgress)
            }
        }
    }

    func removePlaybackTimeObserver() {
        if let timeObserver = timeObserver {
            strategy.player.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
    }

    func addPlayerStatusObserver() {
        self.playerStatusObserver = self.strategy.player.observe(
            \.status,
            options: [.new, .old],
            changeHandler: { [weak self] item, _ in
                if item.status == .failed {
                    self?.isError = true
                }
                Kinescope.shared.logger?.log(message: "AVPlayer.Status – \(item.status.rawValue)",
                                             level: KinescopeLoggerLevel.player)
                self?.delegate?.player(changedStatusTo: item.status)
            }
        )
    }

    func removePlayerStatusObserver() {
        self.playerStatusObserver?.invalidate()
        self.playerStatusObserver = nil
    }

    func addPlayerItemStatusObserver() {
        self.itemStatusObserver = self.strategy.player.currentItem?.observe(
            \.status,
            options: [.new, .old],
            changeHandler: { [weak self] item, _ in
                guard
                    let self = self
                else {
                    return
                }

                switch item.status {
                case .readyToPlay:
                    self.isError = false
                    let seconds = self.savedTime.seconds
                    if seconds > .zero {
                        self.time = seconds
                        self.savedTime = .zero
                        self.seek(to: seconds)
                        self.strategy.player.rate = self.currentSpeed.rawValue
                    }
                case .failed, .unknown:
                    self.isError = true
                    Kinescope.shared.logger?.log(message: "AVPlayerItem.error – \(String(describing: item.error))",
                                                 level: KinescopeLoggerLevel.player)
                default:
                    break
                }

                Kinescope.shared.logger?.log(message: "AVPlayerItem.Status – \(item.status.rawValue)",
                                             level: KinescopeLoggerLevel.player)
                self.delegate?.player(changedItemStatusTo: item.status)
            }
        )
    }

    func removePlayerItemStatusObserver() {
        self.itemStatusObserver?.invalidate()
        self.itemStatusObserver = nil
    }

    func addPlayerTimeControlStatusObserver() {
        self.timeControlStatusObserver = self.strategy.player.observe(
            \.timeControlStatus,
            options: [.new, .old],
            changeHandler: { [weak self] item, _ in
                guard let self = self, !self.isError else {
                    return
                }
                self.isPlaying = item.timeControlStatus == .playing
                switch item.timeControlStatus {
                case .paused:
                    self.isLoading = false
                    self.playbackManager?.stopBuffering()
                case .playing:
                    self.isLoading = false
                    self.playbackManager?.stopBuffering()
                    if self.strategy.player.rate != self.currentSpeed.rawValue {
                        self.strategy.player.rate = self.currentSpeed.rawValue
                    }
                case .waitingToPlayAtSpecifiedRate:
                    self.isLoading = true
                    self.playbackManager?.startBuffering()
                @unknown default:
                    break
                }

                Kinescope.shared.logger?.log(
                    message: "AVPlayer.TimeControlStatus – \(item.timeControlStatus.rawValue)",
                    level: KinescopeLoggerLevel.player
                )
                self.delegate?.player(changedTimeControlStatusTo: item.timeControlStatus)
            }
        )
    }

    func removePlayerTimeControlStatusObserver() {
        self.timeControlStatusObserver?.invalidate()
        self.timeControlStatusObserver = nil
    }

    func addTracksObserver() {
        self.tracksObserver = self.strategy.player.currentItem?.observe(
            \.tracks,
            options: [.new, .old],
            changeHandler: { [weak self] item, _ in
                guard
                    let self = self,
                    let video = self.video,
                    let size = item.tracks.first?.assetTrack?.naturalSize,
                    let frameRate = item.tracks.first?.assetTrack?.nominalFrameRate
                else {
                    return
                }

                let height = String(format: "%.0f", size.height)

                let qualities = video.qualities
                    .filter { $0.hasPrefix(height) }

                let expectedQuality: String?
                if frameRate > 30.0 {
                    expectedQuality = qualities.first { $0.hasSuffix("60") }
                } else {
                    expectedQuality = qualities.first { $0.hasPrefix(height) && !$0.hasSuffix("60") }
                }

                guard
                    let quality = expectedQuality
                else {
                    return
                }

                self.view?.change(quality: quality, manualQuality: self.isManualQuality)
                self.innerEventsHandler.setPlayback(quality: quality)
                self.innerEventsHandler.autoqualitychanged()
                self.dependencies.eventsCenter.post(event: .autoqualitychanged, userInfo: nil)

                Kinescope.shared.logger?.log(
                    message: "AVPlayerItem.presentationSize – \(item.presentationSize)",
                    level: KinescopeLoggerLevel.player
                )
                self.delegate?.player(changedPresentationSizeTo: item.presentationSize)
            }
        )
    }

    func removeTracksObserver() {
        self.tracksObserver?.invalidate()
        self.tracksObserver = nil
    }

    func addNotofications() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(changeOrientation),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didAirPlayStateChanged),
                                               name: AVAudioSession.routeChangeNotification,
                                               object: nil)
    }

    func seek(to seconds: TimeInterval) {
        let duration = strategy.player.currentItem?.duration.seconds ?? .zero
        if seconds >= duration {
            pause()
        }
        self.isSeeking = true
        let time = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

        Kinescope.shared.logger?.log(message: "timeline changed to \(seconds) seconds",
                                     level: KinescopeLoggerLevel.player)
        delegate?.player(didSeekTo: seconds)

        strategy.player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            self?.isSeeking = false
        }
        innerEventsHandler.seek()
        dependencies.eventsCenter.post(event: .seek, userInfo: nil)
    }

    @objc
    func changeOrientation() {
        guard
            let view = view,
            view.canBeFullScreen,
            !KinescopeFullscreenConfiguration.preferred(for: video).orientation.isPortrait
        else {
            return
        }

        let isFullScreen = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController is KinescopeFullscreenViewController
        let isLandscape = [UIDeviceOrientation.landscapeLeft, UIDeviceOrientation.landscapeRight]
            .contains(UIDevice.current.orientation)

        if isLandscape && !isFullScreen {
            didPresentFullscreen(from: view)
        } else if UIDevice.current.orientation.isPortrait && isFullScreen {
            didPresentFullscreen(from: view)
        }
    }

    @objc func appDidEnterForeground() {
        if !(view?.pipController?.isPictureInPictureActive ?? false) {
            view?.playerView.player = strategy.player
        }
    }

    @objc func appDidEnterBackground() {
        if !(view?.pipController?.isPictureInPictureActive ?? false) {
            view?.playerView.player = nil
        }
    }

    @objc
    func didAirPlayStateChanged(_ notification: NSNotification) {
        // Workaround. When player enters in AirPlay mode, timeControlStatus sets in pause even though video is playing
        // So we are looking at player rate to know what current view state is, but rate has correct state only after ~0.5 sec
        airPlayDebouncer.renewInterval()
        airPlayDebouncer.handler = { [weak self] in
            guard let self = self else { return }
            self.isPlaying = self.strategy.player.rate > 0.0
            self.updateTimeline()
            self.view?.controlPanel?.expanded = false
        }
    }

    func restoreView() {
        view?.change(quality: self.currentQuality, manualQuality: self.isManualQuality)
        view?.change(speed: currentSpeed.toString())
        view?.showOverlay(isOverlayed)
        isPlaying ? play() : pause()
    }

    func updateTimeline() {
        let duration = strategy.player.currentItem?.duration.seconds ?? .zero
        let position = CGFloat(time / duration)

        if !position.isNaN {
            view?.controlPanel?.setTimeline(to: CGFloat(position))
        }
        if !time.isNaN {
            view?.controlPanel?.setIndicator(to: time)
        }
    }

    func updateViewState() {
        guard !isError else {
            view?.state = .error
            return
        }
        guard !isLoading else {
            loadingDebouncer.renewInterval()
            addLoadingDebouncerHandler()
            return
        }
        switch (isPlaying, isAtEnd) {
        case (false, true):
            view?.state = .ended
        case (false, false):
            pauseDebouncer.renewInterval()
            addPauseDebouncerHandler()
        case (true, false):
            view?.state = .playing
        case (true, true):
            break
        }
    }

    func addLoadingDebouncerHandler() {
        loadingDebouncer.handler = { [weak self] in
            guard let self = self else {
                return
            }
            guard !self.isError else {
                return
            }
            if self.strategy.player.timeControlStatus == .waitingToPlayAtSpecifiedRate {
                self.view?.state = self.time == 0 ? .initialLoading : .loading
            }
        }
    }

    func addPauseDebouncerHandler() {
        pauseDebouncer.handler = { [weak self] in
            guard let self = self else {
                return
            }
            guard !self.isError, !self.isLoading else {
                return
            }
            if self.strategy.player.timeControlStatus == .paused {
                self.view?.state =  .paused
            }
        }
    }

    func loadManifest() {
        guard let video = video else {
            return
        }
        dependencies.inspector.fetchPlaylist(link: video.hlsLink) { [weak self] result in
            guard let self = self else {
                return
            }
            DispatchQueue.main.async {
                switch result {
                case .success(let playlist):
                    self.video?.manifest = playlist
                    self.view?.set(options: self.makePlayerOptions(from: video))
                case .cancelled, .failure:
                    break
                }
            }
        }
    }

    func getCurrentQuality() -> KinescopeVideoQuality? {
        if let asset = video?.downloadableAssets.first(where: { $0.quality == currentQuality }) {
            if let path = dependencies.assetDownloader.getLocation(by: asset.id) {
                return KinescopeAssetVideoQuality(video: path.absoluteString,
                                                  audio: currentAudio,
                                                  subtitles: currentSutitle?.url)
            }
        }
        if let exactLink = video?.link(for: currentQuality) {
            return KinescopeStreamVideoQuality(hlsLink: exactLink,
                                               audioLocale: nil,
                                               subtitlesLocale: currentSutitle?.language,
                                               isAuto: false)
        }
        if let link = video?.hlsLink {
            return KinescopeStreamVideoQuality(hlsLink: link,
                                               audioLocale: nil,
                                               subtitlesLocale: currentSutitle?.language,
                                               isAuto: true)
        } else {
            return nil
        }
    }

}


// MARK: - CallObserverDelegate

extension KinescopeVideoPlayer: CallObserverDelegate {

    func callObserver(callState: KinescopeCallState) {
        delegate?.didGetCall(callState: callState)
    }

}

// MARK: - KinescopePlayerViewDelegate

extension KinescopeVideoPlayer: KinescopePlayerViewDelegate {

    func didPlayPause() {
        switch (isPlaying, isAtEnd) {
        case (false, true):
            time = .zero
            seek(to: time)
            play()
            innerEventsHandler.replay()
            dependencies.eventsCenter.post(event: .replay, userInfo: nil)
        case (false, false):
            play()
        case (true, false):
            pause()
        case (true, true):
            break
        }
    }

    func didSeek(to position: Double) {
        isPreparingSeek = true

        guard var duration = strategy.player.currentItem?.duration.seconds else {
            return
        }
        if duration.isNaN {
            duration = video?.duration ?? .nan
        }

        Kinescope.shared.logger?.log(message: "timeline seeked to \(position)",
                                     level: KinescopeLoggerLevel.player)

        time = min(duration, position * duration)

        delegate?.player(timelinePositionMovedTo: position)
    }

    func didConfirmSeek() {
        isPreparingSeek = false
        Kinescope.shared.logger?.log(message: "timeline change to time: \(time) confirmed",
                                     level: KinescopeLoggerLevel.player)
        seek(to: time)
    }

    func didSelect(option: KinescopePlayerOption) {
    }

    func didFastForward(sec: Double) {
        guard
            let duration = strategy.player.currentItem?.duration.seconds
        else {
            return
        }

        Kinescope.shared.logger?.log(message: "fast forward +\(sec)s", level: KinescopeLoggerLevel.player)

        time = min(duration, time + sec)
        seek(to: time)

        delegate?.player(didFastForwardTo: time)
    }

    func didFastBackward(sec: Double) {
        Kinescope.shared.logger?.log(message: "fast backward -\(sec)s", level: KinescopeLoggerLevel.player)

        time = max(time - sec, .zero)
        seek(to: time)

        delegate?.player(didFastBackwardTo: time)
    }

    func didPresentFullscreen(from view: KinescopePlayerView) {
        let rootVC = UIApplication.shared.keyWindow?.rootViewController

        if rootVC?.presentedViewController is KinescopeFullscreenViewController {
            isOverlayed = view.overlay?.isSelected ?? false
            detach(view: view)

            rootVC?.dismiss(animated: true, completion: { [weak self] in
                guard
                    let self = self,
                    let miniView = self.miniView
                else {
                    return
                }

                self.attach(view: miniView)
                self.restoreView()
            })
            innerEventsHandler.exitfullscreen()
            dependencies.eventsCenter.post(event: .exitfullscreen, userInfo: nil)
        } else {
            miniView = view
            isOverlayed = view.overlay?.isSelected ?? false

            detach(view: view)

            let playerVC = KinescopeFullscreenViewController(player: self,
                                                             config: .preferred(for: video))
            playerVC.modalPresentationStyle = .overFullScreen
            playerVC.modalTransitionStyle = .crossDissolve
            playerVC.modalPresentationCapturesStatusBarAppearance = true

            rootVC?.present(playerVC, animated: true, completion: { [weak self] in
                guard
                    let self = self,
                    let video = self.video
                else {
                    return
                }
                self.restoreView()
                self.view?.set(title: video.title, subtitle: video.description)
            })
            innerEventsHandler.enterfullscreen()
            dependencies.eventsCenter.post(event: .enterfullscreen, userInfo: nil)
        }
    }

    func didShowQuality() -> [String] {
        return video?.qualities ?? []
    }

    func didShowAttachments() -> [KinescopeVideoAdditionalMaterial]? {
        return video?.additionalMaterials
    }

    func didShowSpeeds() -> [String] {
        KinescopePlayerSpeed.allCases.map { $0.toString() }
    }

    func didShowAssets() -> [KinescopeVideoAsset]? {
        return video?.downloadableAssets
    }

    func didSelect(quality: String) {
        guard
            video != nil
        else {
            Kinescope.shared.logger?.log(message: "Can't find video",
                                         level: KinescopeLoggerLevel.player)
            return
        }

        currentQuality = quality
        if let currentQuality = getCurrentQuality() {
            select(quality: currentQuality)
            Kinescope.shared.logger?.log(message: "Select quality: \(quality)",
                                         level: KinescopeLoggerLevel.player)

            delegate?.player(changedQualityTo: quality)
        }
    }

    func didSelect(speed: String) {
        if let speedCase = KinescopePlayerSpeed.from(string: speed) {
            set(speed: speedCase)
        }
    }

    func didSelectAttachment(with index: Int) {
        guard
            let attachment = video?.additionalMaterials[safe: index]
        else {
            return
        }
        dependencies.attachmentDownloader.enqueueDownload(attachment: attachment)
        Kinescope.shared.logger?.log(message: "Start downloading attachment: \(attachment.title)",
                                     level: KinescopeLoggerLevel.player)
    }

    func didSelectAsset(with index: Int) {
        guard let asset = video?.downloadableAssets[safe: index] else {
            return
        }
        dependencies.assetDownloader.enqueueDownload(asset: asset)
        Kinescope.shared.logger?.log(message: "Start downloading asset: \(asset.id + asset.originalName)",
                                     level: KinescopeLoggerLevel.player)
    }

    func didSelectDownloadAll(for title: String) {
        switch SideMenu.DescriptionTitle.getType(by: title) {
        case .attachments:
            video?.additionalMaterials.forEach {
                dependencies.attachmentDownloader.enqueueDownload(attachment: $0)
                Kinescope.shared.logger?.log(message: "Start downloading attachment: \($0.title)",
                                             level: KinescopeLoggerLevel.player)
            }
        case .download:
            video?.downloadableAssets.forEach {
                dependencies.assetDownloader.enqueueDownload(asset: $0)
                Kinescope.shared.logger?.log(message: "Start downloading asset: \($0.quality) - \($0.id)",
                                             level: KinescopeLoggerLevel.player)
            }
        case .none:
            break
        }
    }

    func didShowSubtitles() -> [String] {
        return video?.subtitles.compactMap { $0.title } ?? []
    }

    func didRefresh() {
        load()
    }

    func didSelect(subtitles: String) {
        guard
            let video = video
        else {
            Kinescope.shared.logger?.log(message: "Can't find video",
                                         level: KinescopeLoggerLevel.player)
            return
        }

        self.currentSutitle = video.subtitles.first(where: { $0.title == subtitles })
        if let currentQuality = getCurrentQuality() {
            select(quality: currentQuality)
        }

        self.strategy.player.currentItem?.textStyleRules = textStyleRules

        let isOn = video.subtitles.contains { $0.title == subtitles }
        view?.controlPanel?.set(subtitleOn: isOn)
        Kinescope.shared.logger?.log(message: "Select subtitles: \(subtitles)",
                                     level: KinescopeLoggerLevel.player)
    }

}

// MARK: - PlaybackManagerDelegate

extension KinescopeVideoPlayer: PlaybackManagerDelegate {

    func uniqueSecondsUpdated(seconds: Int) {
        innerEventsHandler.setSession(watchedDuration: seconds)
    }

    func viewSecondsReached() {
        innerEventsHandler.view()
        dependencies.eventsCenter.post(event: .view, userInfo: nil)
    }

    func playbackActionTriggered(second: Int) {
        innerEventsHandler.playback(sec: second)
        dependencies.eventsCenter.post(event: .playback, userInfo: nil)
    }

    func bufferingActionTriggered(time: TimeInterval) {
        innerEventsHandler.buffering(sec: time)
        dependencies.eventsCenter.post(event: .buffering, userInfo: ["value": time])
    }

}

// swiftlint:enable file_length
