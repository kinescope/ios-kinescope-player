import AVFoundation
import Metal
import UIKit
import KinescopeSDK

final class EnterViewController: UIViewController {

    @IBOutlet weak var field: UITextField!
    @IBOutlet weak var uiSwitch: UISwitch!

    private enum Sample {
        static let custom = "b138bf19-72fc-474b-901b-00f323899598"
        static let drm = "eNWM8F6wbVTVa8fBeR66y6"
        static let subtitles = "4CCHqgs4MkL33akyL7jJtS"
        static let chapters = "mMLazQrkPgThuhB7kkzQ69"
    }

    private var pendingPlaylist: [KinescopePlaylistItem] = []
    /// Built while the menu is idle, so the first open does not assemble the screen mid-transition.
    private var preparedShorts: KinescopeShortsViewController?
    private var preparedPlaylist: PlaylistTestViewController?

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Kinescope"
        field.text = Sample.custom
        installCatalog()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        KinescopeDashboard.videos(perPage: 100,
                                  projectId: KinescopeDemoConfig.projectId,
                                  folderId: KinescopeDemoConfig.folderId) { _ in }
        PlaybackWarmup.start { [weak self] in
            self?.prepareDestinationScreens()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "Player",
              let destination = segue.destination as? VideoViewController,
              let videoId = sender as? String else {
            return
        }
        destination.videoId = videoId
        destination.uiEnabled = true
        destination.demoPlaylist = pendingPlaylist
        pendingPlaylist = []
    }

    @IBAction func didTapPlay(_ sender: Any) {
    }
    
}

private extension EnterViewController {

    func installCatalog() {
        view.subviews.forEach { $0.removeFromSuperview() }

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -24),
            stack.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -16)
        ])

        let examples: [(String, () -> Void)] = [
            ("Playlist test", { [weak self] in self?.openPlaylist() }),
            ("Subtitles test", { [weak self] in self?.showPlayer(for: Sample.subtitles) }),
            ("Chapters test", { [weak self] in self?.showPlayer(for: Sample.chapters) }),
            ("DRM viewing", { [weak self] in self?.showPlayer(for: Sample.drm) }),
            ("Custom player", { [weak self] in self?.openCustomPlayer() }),
            ("Live test", { [weak self] in self?.openLive() }),
            ("Shorts", { [weak self] in self?.showShortsNotice() }),
            ("Saved videos", { [weak self] in self?.showDownloaded() })
        ]
        examples.forEach { title, action in
            stack.addArrangedSubview(makeButton(title: title, action: action))
        }
    }

    func makeButton(title: String, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(red: 0.38, green: 0.38, blue: 0.988, alpha: 1)
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return button
    }

    func openCustomPlayer() {
        navigationController?.pushViewController(CustomPlayerViewController(videoId: Sample.custom), animated: true)
    }

    func openPlaylist() {
        let playlist = preparedPlaylist ?? PlaylistTestViewController()
        preparedPlaylist = nil
        navigationController?.pushViewController(playlist, animated: true)
    }

    func showDownloaded() {
        let list = DownloadedListViewController()
        let nav = UINavigationController(rootViewController: list)
        present(nav, animated: true)
    }

    func openLive() {
        navigationController?.pushViewController(LiveTestViewController(), animated: true)
    }

    func showShortsNotice() {
        let shorts = preparedShorts ?? KinescopeShortsViewController(projectId: KinescopeDemoConfig.projectId,
                                                                     folderId: KinescopeDemoConfig.folderId)
        preparedShorts = nil
        navigationController?.pushViewController(shorts, animated: true)
    }

    /// Assembles the two heavy screens before the tap. Playback still starts only once a screen is shown.
    func prepareDestinationScreens() {
        if preparedShorts == nil {
            let shorts = KinescopeShortsViewController(projectId: KinescopeDemoConfig.projectId,
                                                       folderId: KinescopeDemoConfig.folderId)
            shorts.prepareForOpen()
            preparedShorts = shorts
        }
        DispatchQueue.main.async { [weak self] in
            guard let self, self.preparedPlaylist == nil else { return }
            let playlist = PlaylistTestViewController()
            playlist.prepareForOpen()
            self.preparedPlaylist = playlist
        }
    }

    func showPlayer(for videoId: String) {
        performSegue(withIdentifier: "Player", sender: videoId)
    }

}

/// The first launch after install pays for the media server, fonts and the first HLS open.
/// Doing that while the menu is idle makes the first shorts open feel like the next launch.
enum PlaybackWarmup {
    private static var started = false

    /// Keeps the media process up so the first real player does not start it.
    private static var idlePlayer: AVPlayer?

    /// `ready` runs on the main thread once the decoded art exists, so screens built next use it.
    static func start(ready: @escaping () -> Void = {}) {
        guard !started else {
            DispatchQueue.main.async(execute: ready)
            return
        }
        started = true
        DispatchQueue.main.async {
            idlePlayer = AVPlayer()
            let width = UIScreen.main.bounds.width
            // Playlist opens with the full control chrome at 211pt. Build that once while the menu is idle.
            warm(layout: .default, size: CGSize(width: width, height: 211))
            let shortsLayout = KinescopePlayerViewConfiguration.builder()
                .setGravity(.resizeAspect)
                .setOverlay(nil)
                .setControlPanel(nil)
                .setShadowOverlay(nil)
                .setPictureInPicture(false)
                .build()
            warm(layout: shortsLayout, size: CGSize(width: width, height: UIScreen.main.bounds.height))
        }
        DispatchQueue.global(qos: .utility).async {
            // The first image decode with scaling creates the Metal device. Create it here, off the main thread.
            _ = MTLCreateSystemDefaultDevice()
            DispatchQueue.main.async(execute: ready)
        }
    }

    private static func warm(layout: KinescopePlayerViewConfiguration, size: CGSize) {
        let view = KinescopePlayerView()
        view.frame = CGRect(origin: .zero, size: size)
        view.setLayout(with: layout)
        view.layoutIfNeeded()
    }
}
