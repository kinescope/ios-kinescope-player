import UIKit
import KinescopeSDK
import MediaPlayer

final class VideoViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var playerView: KinescopePlayerView!

    // MARK: - Private properties

    var videoId = ""
    private var player: KinescopePlayer?

    // MARK: - Lifecycle

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.delegate = self

        playerView.setLayout(with: .default)

        PipManager.shared.closePipIfNeeded(with: videoId)

        player = KinescopeVideoPlayer(config: .init(videoId: videoId))
        player?.attach(view: playerView)
        player?.play()
        playerView.showOverlay(true)
        player?.pipDelegate = PipManager.shared
        player?.delegate = self
        setupCommandCenter()
    }

    private func setupCommandCenter() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle: "Some title"]

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

}

// MARK: - UINavigationControllerDelegate

extension VideoViewController: UINavigationControllerDelegate {
    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return self.supportedInterfaceOrientations
    }
}

 // MARK: - KinescopeVideoPlayerDelegate

extension VideoViewController: KinescopeVideoPlayerDelegate {

    func didGetCall(callState: KinescopeCallState) {
        if callState == .ended {
            player?.play()
        }
    }

    func playerDidPlay() {
        print("DIDPLAY")
    }

}
