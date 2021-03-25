import UIKit
import KinescopeSDK

final class VideoViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var playerView: KinescopePlayerView!

    // MARK: - Private properties

    var videoId = ""
    private var player: KinescopeVideoPlayer?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true

        player = KinescopeVideoPlayer(videoId: videoId)
        player?.delegate = self
        playerView.player = player
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
        player = nil
    }
}

// MARK: - KinescopePlayerDelegate

extension VideoViewController: KinescopePlayerDelegate {
    func kinescopePlayerDidReadyToPlay(player: KinescopePlayer) {
        activityIndicator.stopAnimating()

        player.play()
    }

    func kinescopePlayerDataLoadingFailed(player: KinescopePlayer, error: Error) {
        debugPrint(error)
    }
}
