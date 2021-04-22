import UIKit
import KinescopeSDK
import CallKit

final class VideoViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var playerView: KinescopePlayerView!

    // MARK: - Private properties

    var videoId = ""
    private var player: KinescopePlayer?
    private let callObserver = CXCallObserver()

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
        callObserver.setDelegate(self, queue: nil)
    }

}

// MARK: - UINavigationControllerDelegate

extension VideoViewController: UINavigationControllerDelegate {
    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return self.supportedInterfaceOrientations
    }
}

// MARK: - CXCallObserverDelegate

extension VideoViewController: CXCallObserverDelegate {
    
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if call.hasConnected {
            print("Call Connect -> \(call.uuid)")
        }

        if call.isOutgoing {
            print("Call outGoing \(call.uuid)")
        }

        if call.hasEnded {
            player?.play()
        }

        if call.isOnHold {
            print("Call onHold \(call.uuid)")
        }
    }

}
