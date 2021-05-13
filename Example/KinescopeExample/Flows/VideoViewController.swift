import UIKit
import KinescopeSDK
import MediaPlayer

final class VideoViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var playerView: KinescopePlayerView!
    @IBOutlet private weak var previewView: KinescopePreviewView!

    // MARK: - Private properties

    var video: KinescopeVideo?
    private var player: KinescopePlayer?

    // MARK: - Lifecycle

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.delegate = self

        playerView.setLayout(with: .default)

        PipManager.shared.closePipIfNeeded(with: video?.id ?? "")

        player = KinescopeVideoPlayer(config: .init(videoId: video?.id ?? ""))
        player?.attach(view: playerView)
        playerView.showOverlay(true)
        configurePreviewView()

        player?.pipDelegate = PipManager.shared
        player?.delegate = self
        setupCommandCenter()
    }

    private func setupCommandCenter() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle: video?.title ?? "some title"]

        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            self?.player?.play()
            return .success
        }
        commandCenter.pauseCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            self?.player?.pause()
            return .success
        }
    }

    private func configurePreviewView() {
        guard let video = video else {
            return
        }
        player?.setVideo(video)
        let previewModel = KinescopePreviewModel(from: video)

        previewView.delegate = self
        previewView.setPreview(with: previewModel)
        previewView.backgroundColor = .black
        previewView.previewImageView.contentMode = .scaleAspectFit
        previewView.previewImageView.kf.setImage(with: URL(string: video.poster?.md ?? ""))

        playerView.previewImage.contentMode = .scaleAspectFit
        playerView.previewImage.kf.setImage(with: URL(string: video.poster?.md ?? ""))
        view.bringSubviewToFront(previewView)
    }

}

// MARK: - UINavigationControllerDelegate

extension VideoViewController: UINavigationControllerDelegate {
    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return KinescopeFullscreenConfiguration.orientations(for: video)
    }
}

// MARK: - KinescopePreviewViewDelegate

extension VideoViewController: KinescopePreviewViewDelegate {

    func didTap() {
        player?.play()
        previewView.removeFromSuperview()
    }

}
// MARK: - KinescopeVideoPlayerDelegate

extension VideoViewController: KinescopeVideoPlayerDelegate {

    func didGetCall(callState: KinescopeCallState) {
        if callState == .ended {
            player?.play()
        }
    }

}
