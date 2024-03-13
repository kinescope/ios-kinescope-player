import UIKit
import KinescopeSDK

final class VideoViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var playerView: KinescopePlayerView!

    // MARK: - Private properties

    // Change this id to your video id from dashboard. This one is free video for demo of SDK only.
    private let videoId: String = {
#if targetEnvironment(simulator)
        "9L8KmbNuhQSxQofn5DR4Vg"
#else
        "b6a0ce69-3135-496d-8064-c8ed51ac4b2e"
#endif
    }()
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
        player?.pipDelegate = PipManager.shared
    }

}

extension VideoViewController: UINavigationControllerDelegate {
    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return self.supportedInterfaceOrientations
    }
}
