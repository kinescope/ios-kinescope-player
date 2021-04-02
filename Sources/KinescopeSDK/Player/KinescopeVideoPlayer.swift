import AVFoundation

public class KinescopeVideoPlayer: KinescopePlayer {

    // MARK: - Private Properties

    private let dependencies: KinescopePlayerDependencies
    private lazy var strategy: PlayingStrategy = {
        dependencies.provide(for: config)
    }()

    private weak var view: KinescopePlayerView?
    private weak var delegate: KinescopePlayerDelegate?
    private var timeObserver: Any?
    private var statusObserver: NSKeyValueObservation?

    private var isSeeking = false

    private var video: KinescopeVideo?
    private let config: KinescopePlayerConfig

    // MARK: - Lifecycle

    init(config: KinescopePlayerConfig,
         dependencies: KinescopePlayerDependencies,
         delegate: KinescopePlayerDelegate? = nil) {
        self.dependencies = dependencies
        self.config = config
        self.delegate = delegate
    }

    deinit {
        self.removePlaybackTimeObserver()
        self.removeItemStatusObserver()
    }

    // MARK: - KinescopePlayer

    public required convenience init(config: KinescopePlayerConfig, delegate: KinescopePlayerDelegate? = nil) {
        self.init(config: config, dependencies: KinescopeVideoPlayerDependencies(), delegate: delegate)
    }

    public func play() {
        if video != nil {
            self.strategy.play()
        } else {
            self.load()
        }
    }

    public func pause() {
        self.strategy.pause()
        self.removeItemStatusObserver()
    }

    public func stop() {
        self.strategy.pause()
        self.strategy.unbind()
        self.removeItemStatusObserver()
    }

    public func attach(view: KinescopePlayerView) {

        view.playerView.player = self.strategy.player
        view.delegate = self

        self.view = view

        observePlaybackTime()
    }

    public func detach(view: KinescopePlayerView) {
        view.playerView.player = nil
        self.view = nil
        view.delegate = nil

        removePlaybackTimeObserver()
    }

    public func select(quality: KinescopeVideoQuality) {
        guard let item = quality.item else {
            // Log here critical error
            return
        }

        // Restore here sek position

        strategy.bind(item: item)
        self.addItemStatusObserver()
    }

}

// MARK: - Private

private extension KinescopeVideoPlayer {

    /// Sends request video by id and sets player's item
    func load() {
        view?.startLoader()

        dependencies.inspector.video(
            id: config.videoId,
            onSuccess: { [weak self] video in
                self?.video = video
                self?.select(quality: .auto(hlsLink: video.hlsLink))
                self?.view?.overlay?.set(title: video.title, subtitle: video.description)
                self?.view?.stopLoader()
                self?.play()
            },
            onError: { [weak self] error in
                self?.view?.stopLoader()
                debugPrint(error)
            }
        )
    }

    func observePlaybackTime() {

        guard view?.controlPanel != nil else {
            return
        }

        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let period = CMTimeMakeWithSeconds(0.05, preferredTimescale: timeScale)

        timeObserver = strategy.player.addPeriodicTimeObserver(forInterval: period,
                                                               queue: .main) { [weak self] time in
            let isSeeking = self?.isSeeking ?? false

            /// Do not update timeline and indicator value when seeking to new position
            guard !isSeeking else {
                return
            }

            /// Dose not make sense without control panel and curremtItem
            guard let controlPanel = self?.view?.controlPanel,
                  let currentItem = self?.strategy.player.currentItem else {
                return
            }

            // MARK: - Current time observation

            let time = time.seconds

            Kinescope.shared.logger?.log(message: "playback position changed to \(time) seconds", level: KinescopeLoggerLevel.player)

            controlPanel.setIndicator(to: time)

            let duration = currentItem.duration.seconds

            controlPanel.setTimeline(to: CGFloat(time / duration))

            // MARK: - Preload observation

            let buferredTime = currentItem.loadedTimeRanges.first?.timeRangeValue.end.seconds ?? 0

            Kinescope.shared.logger?.log(message: "playback buffered \(buferredTime) seconds", level: KinescopeLoggerLevel.player)

            controlPanel.setBufferred(progress: CGFloat(buferredTime / duration))
        }

    }

    func removePlaybackTimeObserver() {
        if let timeObserver = timeObserver {
            strategy.player.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
    }

    func addItemStatusObserver() {
        self.statusObserver = self.strategy.player.currentItem?.observe(
            \.status,
            options: [.new, .old],
            changeHandler: { [weak self] item, _ in
                self?.view?.change(status: item.status)
            }
        )
    }

    func removeItemStatusObserver() {
        self.statusObserver?.invalidate()
        self.statusObserver = nil
    }

}

// MARK: - PlayerOverlayViewDelegate

extension KinescopeVideoPlayer: KinescopePlayerViewDelegate {
    func didPlay(videoEnded: Bool) {
        if videoEnded {
            self.strategy.player.seek(to: .zero)
        }

        self.play()
    }

    func didPause() {
        self.pause()
    }

    func didSeek(to position: Double) {

        guard let duration = strategy.player.currentItem?.duration.seconds else {
            return
        }

        Kinescope.shared.logger?.log(message: "timeline changed to \(position)", level: KinescopeLoggerLevel.player)

        let seconds = position * duration
        let time = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

        Kinescope.shared.logger?.log(message: "timeline changed to \(seconds) seconds", level: KinescopeLoggerLevel.player)

        isSeeking = true
        strategy.player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            self?.isSeeking = false
        }
    }
}
