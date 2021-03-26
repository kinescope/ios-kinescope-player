import AVFoundation

public class KinescopeVideoPlayer: KinescopePlayer {

    // MARK: - Private Properties

    private let inspector: KinescopeInspectable
    private let player: AVPlayer
    private let looped: Bool
    private var looper: AVPlayerLooper?
    private let videoId: String
    private weak var view: KinescopePlayerView?

    // MARK: - Lifecycle

    init(videoId: String, looped: Bool = false, inspector: KinescopeInspectable) {
        self.inspector = inspector
        self.player = looped ? AVQueuePlayer() : AVPlayer()
        self.looped = looped
        self.videoId = videoId
    }

    // MARK: - KinescopePlayer

    public required init(videoId: String, looped: Bool = false) {
        self.inspector = Kinescope.shared.inspector
        self.player = looped ? AVQueuePlayer() : AVPlayer()
        self.looped = looped
        self.videoId = videoId
    }

    public func play() {
        self.configure()
    }

    public func pause() {
        self.player.pause()
    }

    public func stop() {
        self.player.pause()

        if self.looped {
            self.looper = nil
        } else {
            self.player.replaceCurrentItem(with: nil)
        }
    }

    public func attach(view: KinescopePlayerView) {
        view.playerView.player = self.player
        self.view = view
    }

    public func detach(view: KinescopePlayerView) {
        view.playerView.player = nil
        self.view = view
    }

    // MARK: - Private Methods

    /// Sends request video by id and sets player's item
    private func configure() {
        view?.startLoader()

        inspector.video(
            id: videoId,
            onSuccess: { [weak self] video in
                guard
                    let self = self,
                    let url = URL(string: video.hlsLink)
                else {
                    return
                }

                let asset = AVAsset(url: url)
                let item = AVPlayerItem(asset: asset)

                if self.looped, let player = self.player as? AVQueuePlayer {
                    self.looper = AVPlayerLooper(player: player, templateItem: item)
                } else {
                    self.player.replaceCurrentItem(with: item)
                }

                self.view?.stopLoader()
                self.player.play()
            },
            onError: { [weak self] error in
                self?.view?.stopLoader()
                debugPrint(error)
            }
        )
    }
}
