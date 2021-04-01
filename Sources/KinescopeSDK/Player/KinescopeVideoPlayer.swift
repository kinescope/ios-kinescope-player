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
        let period = CMTimeMakeWithSeconds(0.1, preferredTimescale: timeScale)

        timeObserver = strategy.player.addPeriodicTimeObserver(forInterval: period,
                                                               queue: .main) { [weak self] time in
            let time = time.seconds
            self?.view?.controlPanel?.setIndicator(to: time)
            Kinescope.shared.logger?.log(message: "current time \(time)", level: KinescopeLoggerLevel.player)
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
            options:  [.new, .old],
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

    func didSelect(option: KinescopePlayerOption) {
        delegate?.didSelect(option: option)
    }
}
