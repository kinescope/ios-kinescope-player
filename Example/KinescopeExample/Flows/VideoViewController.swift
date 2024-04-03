import UIKit
import KinescopeSDK

final class VideoViewController: UIViewController {
    
    // MARK: - Nested Types

    private enum CustomPlayerOption: String {
        case share
    }

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

        playerView.setLayout(with: .accentTimeLineAndPlayButton(with: .orange))

        PipManager.shared.closePipIfNeeded(with: videoId)

        player = KinescopeVideoPlayer(config: .init(videoId: videoId))

        if #available(iOS 13.0, *) {
            if let shareIcon = UIImage(systemName: "square.and.arrow.up")?.withRenderingMode(.alwaysTemplate) {
                player?.addCustomPlayerOption(with: CustomPlayerOption.share, and: shareIcon)
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

    func player(didSelectCustomOptionWith optionId: AnyHashable, anchoredAt view: UIView) {
        guard let option = optionId as? CustomPlayerOption else {
            return
        }

        switch option {
        case .share:
            let items = [player?.config.shareLink]
            let activityViewController = UIActivityViewController(activityItems: items as [Any], 
                                                                  applicationActivities: nil)
            let presentationController = activityViewController.presentationController as? UIPopoverPresentationController
            presentationController?.sourceView = view
            presentationController?.permittedArrowDirections = .down
            present(activityViewController, animated: true)
        }
    }

}
