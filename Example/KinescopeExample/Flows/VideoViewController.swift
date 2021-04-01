import UIKit
import KinescopeSDK

final class VideoViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var playerView: KinescopePlayerView!

    // MARK: - Private properties

    var videoId = ""
    private var player: KinescopePlayer?

    // MARK: - Lifecycle

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        playerView.setLayout(with: .default)

        player = KinescopeVideoPlayer(config: .init(videoId: videoId))
        player?.attach(view: playerView)
        player?.play()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.stop()
    }
}
