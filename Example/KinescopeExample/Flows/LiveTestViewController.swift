import UIKit
import KinescopeSDK

/// Same screen as the Android Live test: a player, a live id field, and Watch live.
final class LiveTestViewController: UIViewController, UITextFieldDelegate {

    private let defaultLiveId = "aLJgR9TJfe2EUBejpH5Fuo"
    private let playerView = KinescopePlayerView()
    private let idField = UITextField()
    private let form = UIStackView()
    private var player: KinescopeVideoPlayer?
    private var didInstall = false

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Live test"
        let back = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                   style: .plain,
                                   target: self,
                                   action: #selector(backTapped))
        navigationItem.leftBarButtonItem = back
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        guard !didInstall else { return }
        didInstall = true
        DispatchQueue.main.async { [weak self] in
            self?.install()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            releasePlayer()
        }
    }

    private func install() {
        playerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playerView)

        idField.placeholder = "Ссылка или id"
        idField.borderStyle = .roundedRect
        idField.autocorrectionType = .no
        idField.autocapitalizationType = .none
        idField.clearButtonMode = .whileEditing
        idField.returnKeyType = .go
        idField.font = .systemFont(ofSize: 16)
        idField.delegate = self

        var watchConfig = UIButton.Configuration.filled()
        watchConfig.title = "Watch live"
        watchConfig.baseBackgroundColor = UIColor(red: 97 / 255, green: 97 / 255, blue: 252 / 255, alpha: 1)
        watchConfig.baseForegroundColor = .white
        watchConfig.cornerStyle = .medium
        watchConfig.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        let watch = UIButton(configuration: watchConfig)
        watch.addTarget(self, action: #selector(watchTapped), for: .touchUpInside)
        watch.setContentHuggingPriority(.required, for: .horizontal)
        watch.setContentCompressionResistancePriority(.required, for: .horizontal)

        form.axis = .horizontal
        form.spacing = 8
        form.alignment = .center
        form.addArrangedSubview(idField)
        form.addArrangedSubview(watch)
        form.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(form)

        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerView.heightAnchor.constraint(equalToConstant: 260),
            form.topAnchor.constraint(equalTo: playerView.bottomAnchor, constant: 16),
            form.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            form.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            idField.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func watchTapped() {
        view.endEditing(true)
        let typed = idField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let liveId = typed.isEmpty ? defaultLiveId : typed
        form.isHidden = true
        play(liveId)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        watchTapped()
        return true
    }

    private func play(_ liveId: String) {
        releasePlayer()
        let player = KinescopeVideoPlayer(config: .init(videoId: liveId))
        player.attach(view: playerView)
        player.play()
        self.player = player
    }

    private func releasePlayer() {
        player?.pause()
        player?.stop()
        player?.detach(view: playerView)
        player = nil
    }
}
