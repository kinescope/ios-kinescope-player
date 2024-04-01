import UIKit
import KinescopeSDK

final class VideoViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var playerView: KinescopePlayerView!

    // MARK: - Private properties

    private var player: KinescopePlayer?

    // MARK: - Public Properties

    var videoId: String = ""

    // MARK: - Appearance

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: - Lifecycle

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let videoId = sender as? String else {
            return
        }
        self.videoId = videoId
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.delegate = self

        playerView.setLayout(with: .default)

        PipManager.shared.closePipIfNeeded(with: videoId)

        player = KinescopeVideoPlayer(config: .init(videoId: videoId))

        if #available(iOS 13.0, *) {
            if let shareIcon = UIImage(systemName: "square.and.arrow.up")?.withRenderingMode(.alwaysTemplate) {
                player?.addCustomPlayerOption(with: "Share", and: shareIcon)
            }
        }
        player?.disableOptions([.airPlay])
        
        player?.setDelegate(delegate: self)
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

extension VideoViewController: KinescopeVideoPlayerDelegate {

    func player(didSelectCustomOptionWith optionId: AnyHashable) {
        debugPrint("KINCO: player didSelectCustomOption \(optionId)")
    }

}
