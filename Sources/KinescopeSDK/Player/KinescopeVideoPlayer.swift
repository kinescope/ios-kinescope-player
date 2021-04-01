import AVFoundation

public class KinescopeVideoPlayer: KinescopePlayer {

    // MARK: - Private Properties

    private let dependencies: KinescopePlayerDependencies
    private lazy var strategy: PlayingStrategy = {
        dependencies.provide(for: config)
    }()

    private weak var view: KinescopePlayerView?
    private var timeObserver: Any?

    private var video: KinescopeVideo?
    private let config: KinescopePlayerConfig


    // MARK: - Lifecycle

    init(config: KinescopePlayerConfig, dependencies: KinescopePlayerDependencies) {
        self.dependencies = dependencies
        self.config = config
    }

    // MARK: - KinescopePlayer

    public required convenience init(config: KinescopePlayerConfig) {
        self.init(config: config, dependencies: KinescopeVideoPlayerDependencies())
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
    }

    public func stop() {
        self.strategy.pause()
        self.strategy.unbind()
    }

    public func attach(view: KinescopePlayerView) {
        view.playerView.player = strategy.player

        self.view = view

        observePlaybackTime()
    }

    public func detach(view: KinescopePlayerView) {
        view.playerView.player = nil
        self.view = nil

        removePlaybackTimeObserver()
    }

    public func select(quality: KinescopeVideoQuality) {
        guard let item = quality.item else {
            // Log here critical error
            return
        }

        // Restore here sek position

        strategy.bind(item: item)
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

        view?.controlPanel?.setIndicator(to: strategy.player.currentTime().seconds)
        
        timeObserver = strategy.player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1),
                                                               queue: .main) { [weak self] time in
            self?.view?.controlPanel?.setIndicator(to: time.seconds)
        }

    }

    func removePlaybackTimeObserver() {
        guard let observer = timeObserver else {
            return
        }
        strategy.player.removeTimeObserver(observer)
        timeObserver = nil
    }
}
