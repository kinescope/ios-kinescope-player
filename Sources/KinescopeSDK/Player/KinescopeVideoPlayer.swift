import AVFoundation

public class KinescopeVideoPlayer: KinescopePlayer {

    // MARK: - Private Properties

    private let inspector: KinescopeInspectable
    private var strategy: KinescopeVideoPlayStrategy

    private weak var view: KinescopePlayerView?

    private var video: KinescopeVideo?
    private let videoId: String

    // MARK: - Public Properties

    public var looped: Bool = false {
        didSet {
            if looped {
                strategy = KinescopeVideoPlayLoopedStrategy()
            } else {
                strategy = KinescopeVideoPlaySingleStrategy()
            }
        }
    }

    // MARK: - Lifecycle

    init(videoId: String, inspector: KinescopeInspectable) {
        self.inspector = inspector
        self.strategy = KinescopeVideoPlaySingleStrategy()
        self.videoId = videoId
    }

    // MARK: - KinescopePlayer

    public required init(videoId: String) {
        self.inspector = Kinescope.shared.inspector
        self.strategy = KinescopeVideoPlaySingleStrategy()
        self.videoId = videoId
    }

    public func play() {
        if let _ = self.video {
            self.strategy.player.play()
        } else {
            self.load()
        }
    }

    public func pause() {
        self.strategy.player.pause()
    }

    public func stop() {
        self.strategy.player.pause()
        self.strategy.ubind()
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
            id: videoId,
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
