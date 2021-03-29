import AVFoundation

public class KinescopeVideoPlayer: KinescopePlayer {

    // MARK: - Private Properties

    private let inspector: KinescopeInspectable
    private lazy var strategy: KinescopeVideoPlayStrategy = {
        if config.looped {
            return KinescopeVideoPlayLoopedStrategy()
        } else {
            return KinescopeVideoPlaySingleStrategy()
        }
    }()

    private weak var view: KinescopePlayerView?

    private var video: KinescopeVideo?
    private let config: KinescopePlayerConfig

    // MARK: - Lifecycle

    init(config: KinescopePlayerConfig, inspector: KinescopeInspectable) {
        self.inspector = inspector
        self.config = config
    }

    // MARK: - KinescopePlayer

    public required init(config: KinescopePlayerConfig) {
        self.inspector = Kinescope.shared.inspector
        self.config = config
    }

    public func play() {
        if let _ = self.video {
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
        view.playerView.player = self.strategy.player
        self.view = view
    }

    public func detach(view: KinescopePlayerView) {
        view.playerView.player = nil
        self.view = view
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

        inspector.video(
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
}
