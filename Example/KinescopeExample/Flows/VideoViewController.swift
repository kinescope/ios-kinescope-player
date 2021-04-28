import UIKit
import KinescopeSDK

final class VideoViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var playerView: KinescopePlayerView!

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
        player?.play()
        playerView.showOverlay(true)
        configurePreviewView()

        player?.pipDelegate = PipManager.shared
    }

    private func configurePreviewView() {
        guard let video = video else {
            return
        }
        let previewModel = KinescopePreviewModel(from: video)

        playerView.previewView.setPreview(with: previewModel)
        playerView.previewView.previewImageView.contentMode = .scaleAspectFit
        playerView.previewView.previewImageView.kf.setImage(with: URL(string: video.poster?.md ?? ""))
    }

}

extension VideoViewController: UINavigationControllerDelegate {
    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return self.supportedInterfaceOrientations
    }
}
