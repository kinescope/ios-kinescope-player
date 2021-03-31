import UIKit
import KinescopeSDK

final class VideoViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var playerView: KinescopePlayerView!

    // MARK: - Private properties

    var videoId = ""
    private var player: KinescopeVideoPlayer?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerView.setLayout(with: .init(gravity: .resizeAspect,
                                         activityIndicator: UIActivityIndicatorView(style: .whiteLarge),
                                         overlay: nil,
                                         controlPanel: .init(tintColor: .gray,
                                                             backgroundColor: .systemBlue,
                                                             preferedHeigh: 40,
                                                             hideOnPlayTimeout: 2,
                                                             timeIndicator: .default,
                                                             timeline: .default,
                                                             optionsMenu: .default)))

        player = KinescopeVideoPlayer(config: .init(videoId: videoId))
        player?.attach(view: playerView)
        player?.play()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.stop()
    }
}
