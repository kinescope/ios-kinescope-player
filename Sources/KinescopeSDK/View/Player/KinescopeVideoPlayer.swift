import AVKit

public class KinescopeVideoPlayer: KinescopePlayer {

    // MARK: - Private Properties

    private let player: AVPlayer
    private let videoId: String

    // MARK: - KinescopePlayer

    public var avPlayer: AVPlayer {
        return self.player
    }

    public var delegate: KinescopePlayerDelegate?
    
    public required init(videoId: String) {
        self.player = AVPlayer()
        self.videoId = videoId
        self.configure()
    }

    public func play() {
        self.player.play()
    }

    public func pause() {
        self.player.pause()
    }

    // MARK: - Private Methods

    /// Sends request video by id and sets player's item
    private func configure() {
        Kinescope.shared.inspector.video(
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
                self.player.replaceCurrentItem(with: item)

                self.delegate?.kinescopePlayerDidReadyToPlay(player: self)
            },
            onError: { [weak self] error in
                guard
                    let self = self
                else {
                    return
                }

                self.delegate?.kinescopePlayerDataLoadingFailed(player: self, error: error)
            }
        )
    }
}
