import UIKit
import KinescopeSDK

final class VideoViewController: UIViewController {

    private enum CustomPlayerOption: String {
        case share
    }

    @IBOutlet private weak var playerView: KinescopePlayerView!

    private var player: KinescopePlayer?
    private var downloadBarButtonItem: UIBarButtonItem?
    private var deleteBarButtonItem: UIBarButtonItem?
    private var isDownloading = false
    private var downloadProgressView: UIProgressView?

    var videoId: String = ""
    var uiEnabled: Bool = true
    /// When set, video is played from this local URL (offline/downloaded playback, including DRM).
    var localVideoURL: URL?

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let videoId = sender as? String else {
            return
        }
        self.videoId = videoId
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            stopPlayerAndRelease()
        }
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            stopPlayerAndRelease()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if player == nil, !videoId.isEmpty {
            setupPlayer()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.delegate = self
        setupBarButtons()
        Kinescope.shared.videoDownloader.add(delegate: self)

        if uiEnabled {
            playerView.setLayout(with: .accentTimeLineAndPlayButton(with: .orange))
        } else {
            playerView.setLayout(with: .builder()
                .setGravity(.resizeAspect)
                .setOverlay(nil)
                .setControlPanel(nil)
                .setShadowOverlay(nil)
                .build()
            )
        }

        PipManager.shared.closePipIfNeeded(with: videoId)
        setupPlayer()
    }

    private func setupPlayer() {
        guard player == nil, !videoId.isEmpty else { return }

        let repeatingMode: RepeatingMode = uiEnabled ? .default : .infinite(interval: .seconds(5))
        player = KinescopeVideoPlayer(config: .init(videoId: videoId,
                                                    looped: !uiEnabled,
                                                    repeatingMode: repeatingMode,
                                                    localPlaybackURL: localVideoURL))

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

    deinit {
        stopPlayerAndRelease()
        Kinescope.shared.videoDownloader.remove(delegate: self)
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

    private func setupBarButtons() {
        let downloadTitle = NSLocalizedString("Download", comment: "")
        let downloadButton = UIBarButtonItem(
            title: downloadTitle,
            style: .plain,
            target: self,
            action: #selector(downloadTapped)
        )
        if #available(iOS 13.0, *) {
            downloadButton.image = UIImage(systemName: "arrow.down.circle")
        }
        downloadBarButtonItem = downloadButton

        let deleteTitle = NSLocalizedString("Delete", comment: "")
        let deleteButton = UIBarButtonItem(
            title: deleteTitle,
            style: .plain,
            target: self,
            action: #selector(deleteTapped)
        )
        if #available(iOS 13.0, *) {
            deleteButton.image = UIImage(systemName: "trash")
        }
        deleteBarButtonItem = deleteButton

        updateBarButtons()
        setupDownloadProgressView()
    }

    private func setupDownloadProgressView() {
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = .systemBlue
        progressView.trackTintColor = .systemGray5
        progressView.isHidden = true
        view.addSubview(progressView)
        downloadProgressView = progressView
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 4)
        ])
    }

    private func updateBarButtons() {
        let downloaded = Kinescope.shared.videoDownloader.isDownloaded(videoId: videoId)
        downloadBarButtonItem?.isEnabled = !isDownloading
        // Use non-empty title when downloading to avoid NavigationButtonBar constraint conflict (width == 0).
        downloadBarButtonItem?.title = isDownloading ? " " : NSLocalizedString("Download", comment: "")
        var items: [UIBarButtonItem] = [downloadBarButtonItem!]
        if downloaded {
            items.append(deleteBarButtonItem!)
        }
        navigationItem.rightBarButtonItems = items
    }

    @objc private func downloadTapped() {
        guard !isDownloading else { return }

        Kinescope.shared.inspector.video(
            id: videoId,
            onSuccess: { [weak self] video in
                self?.startDownload(video: video)
            },
            onError: { [weak self] error in
                self?.showAlert(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription)
            }
        )
    }

    private func startDownload(video: KinescopeVideo) {
        if Kinescope.shared.videoDownloader.isDownloaded(videoId: video.id) {
            let alert = UIAlertController(
                title: NSLocalizedString("Saved", comment: ""),
                message: NSLocalizedString("This video is already saved for offline.", comment: ""),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive) { [weak self] _ in
                self?.performDelete()
            })
            present(alert, animated: true)
            return
        }

        guard let url = URL(string: video.hlsLink) else {
            showAlert(title: NSLocalizedString("Error", comment: ""), message: "Invalid video URL")
            return
        }

        isDownloading = true
        updateDownloadButton(title: NSLocalizedString("Downloading...", comment: ""), enabled: false)
        showDownloadProgress(visible: true, progress: 0)
        Kinescope.shared.videoDownloader.enqueueDownload(videoId: video.id, url: url, video: video)
    }

    private func showDownloadProgress(visible: Bool, progress: Float = 0) {
        downloadProgressView?.setProgress(progress, animated: true)
        downloadProgressView?.isHidden = !visible
    }

    private func updateDownloadButton(title: String?, enabled: Bool) {
        downloadBarButtonItem?.title = title
        downloadBarButtonItem?.isEnabled = enabled
    }

    @objc private func deleteTapped() {
        let alert = UIAlertController(
            title: NSLocalizedString("Delete", comment: ""),
            message: NSLocalizedString("Remove this video from device?", comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive) { [weak self] _ in
            self?.performDelete()
        })
        present(alert, animated: true)
    }

    private func performDelete() {
        let deleted = Kinescope.shared.videoDownloader.delete(videoId: videoId)
        if deleted {
            updateBarButtons()
            showAlert(
                title: NSLocalizedString("Deleted", comment: ""),
                message: NSLocalizedString("Video removed from device.", comment: "")
            )
        } else {
            showAlert(
                title: NSLocalizedString("Error", comment: ""),
                message: NSLocalizedString("Could not delete video.", comment: "")
            )
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        present(alert, animated: true)
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

extension VideoViewController: KinescopeVideoDownloadableDelegate {

    func videoDownloadProgress(videoId: String, progress: Double) {
        guard videoId == self.videoId else { return }
        DispatchQueue.main.async { [weak self] in
            self?.updateDownloadButton(
                title: String(format: NSLocalizedString("Downloading %.0f%%", comment: ""), progress),
                enabled: false
            )
            self?.showDownloadProgress(visible: true, progress: Float(progress / 100.0))
        }
    }

    func videoDownloadError(videoId: String, error: KinescopeDownloadError) {
        guard videoId == self.videoId else { return }
        DispatchQueue.main.async { [weak self] in
            self?.isDownloading = false
            self?.showDownloadProgress(visible: false)
            self?.updateDownloadButton(title: NSLocalizedString("Download", comment: ""), enabled: true)
            self?.showAlert(
                title: NSLocalizedString("Download failed", comment: ""),
                message: error.localizedDescription
            )
        }
    }

    func videoDownloadComplete(videoId: String) {
        guard videoId == self.videoId else { return }
        DispatchQueue.main.async { [weak self] in
            self?.isDownloading = false
            self?.showDownloadProgress(visible: true, progress: 1.0)
            self?.updateDownloadButton(title: NSLocalizedString("Download", comment: ""), enabled: true)
            self?.updateBarButtons()
            self?.showAlert(
                title: NSLocalizedString("Saved", comment: ""),
                message: NSLocalizedString("Video saved for offline playback.", comment: "")
            )
            // Hide progress bar after a short delay so user sees 100%
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.showDownloadProgress(visible: false)
            }
        }
    }

}
