import UIKit
import KinescopeSDK

final class VideoViewController: UIViewController {

    private enum CustomPlayerOption: String {
        case share
    }

    @IBOutlet private weak var playerView: KinescopePlayerView!

    private var player: KinescopePlayer?

    var videoId: String = ""
    var uiEnabled: Bool = true
    var demoPlaylist: [KinescopePlaylistItem] = []
    /// When set, video is played from this local URL (offline/downloaded playback, including DRM).
    var localVideoURL: URL?
    private var didInstallChrome = false

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let videoId = sender as? String else {
            return
        }
        self.videoId = videoId
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        DispatchQueue.main.async { [weak self] in
            guard let self, self.player == nil else { return }
            if !self.didInstallChrome {
                self.didInstallChrome = true
                self.installChrome()
            }
            self.setupPlayer()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            stopPlayerAndRelease()
        }
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            stopPlayerAndRelease()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.delegate = self
        updateBarButtons()
        PipManager.shared.closePipIfNeeded(with: videoId)
    }

    private func installChrome() {
        if uiEnabled {
            playerView.setLayout(with: .default)
        } else {
            playerView.setLayout(with: .builder()
                .setGravity(.resizeAspect)
                .setOverlay(nil)
                .setControlPanel(nil)
                .setShadowOverlay(nil)
                .build()
            )
        }
    }

    private func setupPlayer() {
        guard player == nil, !videoId.isEmpty else { return }

        let repeatingMode: RepeatingMode = uiEnabled ? .default : .infinite(interval: .seconds(5))
        player = KinescopeVideoPlayer(config: .init(videoId: videoId,
                                                    looped: !uiEnabled,
                                                    repeatingMode: repeatingMode,
                                                    localPlaybackURL: localVideoURL))

        player?.disableOptions([.airPlay])
        player?.setDelegate(delegate: self)
        player?.attach(view: playerView)
        if let player = player as? KinescopeVideoPlayer, !demoPlaylist.isEmpty {
            player.setPlaylist(demoPlaylist, currentItemId: videoId)
        }
        player?.play()
        player?.pipDelegate = PipManager.shared
    }

    deinit {
        stopPlayerAndRelease()
    }

    private func stopPlayerAndRelease() {
        guard player != nil else { return }
        player?.pause()
        player?.stop()
        if let view = playerView {
            player?.detach(view: view)
        }
        player = nil
    }

    private func updateBarButtons() {
        let back = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                   style: .plain,
                                   target: self,
                                   action: #selector(backTapped))
        navigationItem.leftBarButtonItem = back
    }

    @objc private func backTapped() {
        if let navigation = navigationController, navigation.viewControllers.first !== self {
            navigation.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

}

extension VideoViewController: UINavigationControllerDelegate {
    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return self.supportedInterfaceOrientations
    }
}

extension VideoViewController: KinescopeVideoPlayerDelegate {

    func player(didSelectPlaylistItem item: KinescopePlaylistItem) {
        guard item.id != videoId else {
            return
        }
        videoId = item.id
        stopPlayerAndRelease()
        setupPlayer()
    }

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
