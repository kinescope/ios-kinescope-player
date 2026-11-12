import UIKit
import AVFoundation
import KinescopeSDK

/// Same screen as the Android Custom Player: a player and the template / playback switches under it.
final class CustomPlayerViewController: UIViewController {

    private let videoId: String
    private let playerView = KinescopePlayerView()
    private var player: KinescopeVideoPlayer?
    private var templates: [PlayerTemplate] = []
    private var selected: PlayerTemplate?

    private var autoplay = true
    private var muted = false
    private var loop = false
    private var controls = true
    private var playsinline = true
    private var keyboardShortcuts = true
    private var pictureInPicture = true
    private var fullscreen = true
    private var playbackRate = true
    private var preload = "metadata"
    private var quality = "auto"
    private var accent = "#6161FC"
    private var didStartPlayer = false
    private var warmMuted = false
    private var playingNow = false
    private var appliedPlayback = false
    private var switchControls: [UISwitch] = []
    private var choiceButtons: [String: UIButton] = [:]
    private var colorField: UITextField?

    init(videoId: String) {
        self.videoId = videoId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "Custom Player"
        navigationController?.navigationBar.barStyle = .black
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        let back = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                   style: .plain,
                                   target: self,
                                   action: #selector(backTapped))
        back.tintColor = .white
        navigationItem.leftBarButtonItem = back
        installPlayer()
        installSettings()
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !didStartPlayer else { return }
        didStartPlayer = true
        DispatchQueue.main.async { [weak self] in
            self?.startPlayer()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            player?.pause()
            player?.stop()
            player?.detach(view: playerView)
            player = nil
        }
    }

    private func installPlayer() {
        playerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playerView)
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerView.heightAnchor.constraint(equalToConstant: 211)
        ])
    }

    override var canBecomeFirstResponder: Bool { keyboardShortcuts }

    override var keyCommands: [UIKeyCommand]? {
        guard keyboardShortcuts else { return nil }
        return [
            UIKeyCommand(input: " ", modifierFlags: [], action: #selector(keyPlayPause)),
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: [], action: #selector(keySeekBack)),
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: [], action: #selector(keySeekForward))
        ]
    }

    private func installSettings() {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: playerView.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -16),
            stack.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -16)
        ])

        stack.addArrangedSubview(header("Player template"))
        stack.addArrangedSubview(button("Save template", color: UIColor(red: 97 / 255, green: 97 / 255, blue: 252 / 255, alpha: 1), action: #selector(saveTemplate)))
        stack.addArrangedSubview(button("Use template", color: UIColor(red: 97 / 255, green: 97 / 255, blue: 252 / 255, alpha: 1), action: #selector(useTemplate)))
        selectedLabel.text = "No template selected"
        stack.addArrangedSubview(selectedLabel)
        stack.addArrangedSubview(button("Update template", color: UIColor(red: 97 / 255, green: 97 / 255, blue: 252 / 255, alpha: 1), action: #selector(updateTemplate)))
        stack.addArrangedSubview(button("Delete template", color: UIColor(red: 0.94, green: 0.27, blue: 0.27, alpha: 1), action: #selector(deleteTemplate)))

        stack.addArrangedSubview(header("Playback"))
        stack.addArrangedSubview(toggle("Autoplay", key: \.autoplay))
        stack.addArrangedSubview(toggle("Muted", key: \.muted))
        stack.addArrangedSubview(toggle("Loop", key: \.loop))
        stack.addArrangedSubview(toggle("Controls", key: \.controls))
        stack.addArrangedSubview(toggle("Playsinline", key: \.playsinline))
        stack.addArrangedSubview(choice("Preload", key: "preload", values: ["none", "metadata", "auto"]))
        stack.addArrangedSubview(choice("Quality", key: "quality", values: ["auto", "360", "480", "720", "1080", "audio"]))
        stack.addArrangedSubview(header("Features"))
        stack.addArrangedSubview(toggle("Keyboard shortcuts", key: \.keyboardShortcuts))
        stack.addArrangedSubview(toggle("Picture in picture", key: \.pictureInPicture))
        stack.addArrangedSubview(toggle("Fullscreen", key: \.fullscreen))
        stack.addArrangedSubview(toggle("Playback rate", key: \.playbackRate))
        stack.addArrangedSubview(colorRow())
    }

    private let selectedLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 2
        return label
    }()

    private func header(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }

    private func button(_ title: String, color: UIColor, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = color.cgColor
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func toggle(_ title: String, key: ReferenceWritableKeyPath<CustomPlayerViewController, Bool>) -> UIStackView {
        let label = UILabel()
        label.text = title
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        let control = UISwitch()
        control.isOn = self[keyPath: key]
        control.onTintColor = UIColor(red: 97 / 255, green: 97 / 255, blue: 252 / 255, alpha: 1)
        control.addAction(UIAction { [weak self] action in
            guard let self, let control = action.sender as? UISwitch else { return }
            let was = self[keyPath: key]
            self[keyPath: key] = control.isOn
            if key == \.loop || key == \.autoplay {
                self.startPlayer()
            } else if key == \.muted {
                self.player?.setVolume(control.isOn ? 0 : 1)
            } else if key == \.playsinline {
                if !control.isOn {
                    self.player?.enterFullscreen()
                }
            } else if key == \.keyboardShortcuts {
                if control.isOn {
                    self.becomeFirstResponder()
                } else {
                    self.resignFirstResponder()
                }
            } else if was != control.isOn {
                self.applyChrome()
            }
        }, for: .valueChanged)
        switchControls.append(control)
        let row = UIStackView(arrangedSubviews: [label, control])
        row.axis = .horizontal
        row.alignment = .center
        return row
    }

    private func choice(_ title: String, key: String, values: [String]) -> UIStackView {
        let label = UILabel()
        label.text = title
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.accessibilityIdentifier = key
        button.addAction(UIAction { [weak self] _ in
            self?.pick(key, values: values, source: button)
        }, for: .touchUpInside)
        choiceButtons[key] = button
        refreshChoice(key)
        let row = UIStackView(arrangedSubviews: [label, button])
        row.axis = .horizontal
        row.alignment = .center
        return row
    }

    private func pick(_ key: String, values: [String], source: UIView) {
        let sheet = UIAlertController(title: key.capitalized, message: nil, preferredStyle: .actionSheet)
        for value in values {
            sheet.addAction(UIAlertAction(title: value, style: .default) { [weak self] _ in
                guard let self else { return }
                if key == "preload" {
                    self.preload = value
                    self.startPlayer()
                } else {
                    self.quality = value
                    self.player?.selectQuality(named: value)
                }
                self.refreshChoice(key)
            })
        }
        sheet.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        sheet.popoverPresentationController?.sourceView = source
        present(sheet, animated: true)
    }

    private func refreshChoice(_ key: String) {
        let value = key == "preload" ? preload : quality
        choiceButtons[key]?.setTitle(value, for: .normal)
    }

    private func colorRow() -> UIStackView {
        let label = UILabel()
        label.text = "Accent color"
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        let field = UITextField()
        field.text = accent
        field.textColor = .white
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.borderStyle = .roundedRect
        field.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        field.widthAnchor.constraint(equalToConstant: 110).isActive = true
        field.addAction(UIAction { [weak self] action in
            guard let self, let text = (action.sender as? UITextField)?.text else { return }
            let hex = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard Self.color(from: hex) != nil else {
                self.toast("Invalid color")
                return
            }
            self.accent = hex.hasPrefix("#") ? hex : "#\(hex)"
            self.applyChrome()
        }, for: .editingDidEnd)
        colorField = field
        let row = UIStackView(arrangedSubviews: [label, field])
        row.axis = .horizontal
        row.alignment = .center
        return row
    }

    private func startPlayer() {
        player?.pause()
        player?.stop()
        player?.detach(view: playerView)
        player = nil
        appliedPlayback = false
        playingNow = false
        applyChrome()
        let next = KinescopeVideoPlayer(config: .init(videoId: videoId, looped: loop))
        player = next
        next.setDelegate(delegate: self)
        next.attach(view: playerView)
        next.setVolume(muted ? 0 : 1)
        applyOptions()
        if autoplay {
            next.play()
        } else if preload == "auto" {
            warmMuted = true
            next.setVolume(0)
            next.play()
        }
        if keyboardShortcuts {
            becomeFirstResponder()
        }
    }

    private func applyChrome() {
        let tint = Self.color(from: accent) ?? UIColor(red: 97 / 255, green: 97 / 255, blue: 252 / 255, alpha: 1)
        if controls {
            playerView.setLayout(with: .accentTimeLineAndPlayButton(with: tint))
        } else {
            playerView.setLayout(with: .builder()
                .setGravity(.resizeAspect)
                .setOverlay(nil)
                .setControlPanel(nil)
                .setShadowOverlay(nil)
                .build())
        }
        playerView.showsPlaybackRateSetting = playbackRate
        player?.attach(view: playerView)
        if controls {
            // A rebuilt layout starts with the bar hidden, and it only came back if playback
            // happened to change state. Show it every time the switch turns the controls on.
            playerView.revealControls(autoHide: player?.isPlaying == true)
        }
    }

    private func applyOptions() {
        var hidden: [KinescopePlayerOption] = [.airPlay]
        if !pictureInPicture {
            hidden.append(.pip)
        }
        if !fullscreen {
            hidden.append(.fullscreen)
        }
        player?.disableOptions(hidden)
    }

    @objc private func useTemplate() {
        loadTemplates { [weak self] in
            guard let self else { return }
            guard !self.templates.isEmpty else {
                self.toast("Failed to load templates")
                return
            }
            let sheet = UIAlertController(title: "Select template", message: nil, preferredStyle: .actionSheet)
            for template in self.templates {
                sheet.addAction(UIAlertAction(title: template.name, style: .default) { [weak self] _ in
                    self?.apply(template)
                })
            }
            sheet.addAction(UIAlertAction(title: "Отмена", style: .cancel))
            sheet.popoverPresentationController?.sourceView = self.view
            self.present(sheet, animated: true)
        }
    }

    private func apply(_ template: PlayerTemplate) {
        selected = template
        selectedLabel.text = "Selected: \(template.name)"
        if let settings = template.settings {
            autoplay = settings.autoplay ?? autoplay
            muted = settings.muted ?? muted
            loop = settings.loop ?? loop
            controls = settings.controls ?? controls
            playsinline = settings.playsinline ?? playsinline
            preload = settings.preload ?? preload
            quality = settings.quality ?? quality
            keyboardShortcuts = settings.keyboardShortcuts ?? keyboardShortcuts
            pictureInPicture = settings.pictureInPicture ?? pictureInPicture
            fullscreen = settings.fullscreen ?? fullscreen
            playbackRate = settings.playbackRate ?? playbackRate
            if let color = settings.color { accent = color }
        }
        startPlayer()
        syncSwitches()
        toast("Template applied: \(template.name)")
    }

    private func syncSwitches() {
        let values = [autoplay, muted, loop, controls, playsinline, keyboardShortcuts, pictureInPicture, fullscreen, playbackRate]
        for (index, control) in switchControls.enumerated() where index < values.count {
            control.setOn(values[index], animated: false)
        }
        refreshChoice("preload")
        refreshChoice("quality")
        colorField?.text = accent
    }

    @objc private func saveTemplate() {
        askName(title: "Save template") { [weak self] name in
            self?.sendTemplate(name: name, id: nil)
        }
    }

    @objc private func updateTemplate() {
        guard let selected else {
            toast("No template selected")
            return
        }
        askName(title: "Update template", preset: selected.name) { [weak self] name in
            self?.sendTemplate(name: name, id: selected.id)
        }
    }

    @objc private func deleteTemplate() {
        guard let selected else {
            toast("No template selected")
            return
        }
        let alert = UIAlertController(title: "Delete template?",
                                      message: "Template \"\(selected.name)\" will be permanently deleted.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.request(path: "v1/players/\(selected.id)", method: "DELETE", body: nil) { [weak self] result in
                if case .success = result {
                    self?.selected = nil
                    self?.selectedLabel.text = "No template selected"
                    self?.toast("Template deleted")
                } else {
                    self?.toast("Failed to delete template")
                }
            }
        })
        present(alert, animated: true)
    }

    private func askName(title: String, preset: String? = nil, done: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = "Player name"
            field.text = preset
        }
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !name.isEmpty else { return }
            done(name)
        })
        present(alert, animated: true)
    }

    private func sendTemplate(name: String, id: String?) {
        let body: [String: Any] = [
            "name": name,
            "settings": [
                "autoplay": autoplay,
                "muted": muted,
                "loop": loop,
                "controls": controls,
                "playsinline": playsinline,
                "preload": preload,
                "quality": quality,
                "keyboard_shortcuts": keyboardShortcuts,
                "picture_in_picture": pictureInPicture,
                "fullscreen": fullscreen,
                "playback_rate": playbackRate,
                "color": accent
            ]
        ]
        let path = id.map { "v1/players/\($0)" } ?? "v1/players"
        request(path: path, method: id == nil ? "POST" : "PUT", body: body) { [weak self] result in
            switch result {
            case .success(let data):
                if let template = Self.template(from: data) {
                    self?.selected = template
                    self?.selectedLabel.text = "Selected: \(template.name)"
                }
                self?.toast(id == nil ? "Template saved: \(name)" : "Template updated: \(name)")
            case .failure:
                self?.toast(id == nil ? "Failed to save template" : "Failed to update template")
            }
        }
    }

    private func loadTemplates(done: @escaping () -> Void) {
        request(path: "v1/players", method: "GET", body: nil) { [weak self] result in
            if case .success(let data) = result {
                self?.templates = Self.templates(from: data)
            }
            done()
        }
    }

    private func request(path: String, method: String, body: [String: Any]?, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let key = Kinescope.shared.config?.apiKey, !key.isEmpty,
              let url = URL(string: "https://api.kinescope.io/\(path)") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            let status = (response as? HTTPURLResponse)?.statusCode ?? 0
            DispatchQueue.main.async {
                if let error {
                    completion(.failure(error))
                } else if (200..<300).contains(status) {
                    completion(.success(data ?? Data()))
                } else {
                    completion(.failure(URLError(.badServerResponse)))
                }
            }
        }.resume()
    }

    private func toast(_ text: String) {
        let label = UILabel()
        label.text = "  \(text)  "
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        label.backgroundColor = UIColor(white: 0.15, alpha: 0.94)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            label.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24)
        ])
        UIView.animate(withDuration: 0.25, delay: 1.6, options: []) {
            label.alpha = 0
        } completion: { _ in
            label.removeFromSuperview()
        }
    }

    private static func templates(from data: Data) -> [PlayerTemplate] {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let rows = json["data"] as? [[String: Any]] else {
            return []
        }
        return rows.compactMap(template(from:))
    }

    private static func template(from data: Data) -> PlayerTemplate? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        let row = (json["data"] as? [String: Any]) ?? json
        return template(from: row)
    }

    private static func template(from row: [String: Any]) -> PlayerTemplate? {
        guard let id = row["id"] as? String, let name = row["name"] as? String else { return nil }
        let settings = row["settings"] as? [String: Any]
        return PlayerTemplate(id: id,
                              name: name,
                              settings: PlayerSettings(autoplay: settings?["autoplay"] as? Bool,
                                                       muted: settings?["muted"] as? Bool,
                                                       loop: settings?["loop"] as? Bool,
                                                       controls: settings?["controls"] as? Bool,
                                                       playsinline: settings?["playsinline"] as? Bool,
                                                       preload: settings?["preload"] as? String,
                                                       quality: settings?["quality"] as? String,
                                                       keyboardShortcuts: settings?["keyboard_shortcuts"] as? Bool,
                                                       pictureInPicture: settings?["picture_in_picture"] as? Bool,
                                                       fullscreen: settings?["fullscreen"] as? Bool,
                                                       playbackRate: settings?["playback_rate"] as? Bool,
                                                       color: settings?["color"] as? String))
    }

    private static func color(from hex: String) -> UIColor? {
        var text = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.hasPrefix("#") { text.removeFirst() }
        guard text.count == 6, let value = Int(text, radix: 16) else { return nil }
        return UIColor(red: CGFloat((value >> 16) & 0xFF) / 255,
                       green: CGFloat((value >> 8) & 0xFF) / 255,
                       blue: CGFloat(value & 0xFF) / 255,
                       alpha: 1)
    }

    @objc private func keyPlayPause() {
        guard let player else { return }
        if playingNow {
            player.pause()
        } else {
            player.play()
        }
    }

    @objc private func keySeekBack() {
        guard let player else { return }
        player.seek(to: max(0, player.currentTime - 10))
    }

    @objc private func keySeekForward() {
        guard let player else { return }
        let limit = player.duration ?? player.currentTime + 10
        player.seek(to: min(limit, player.currentTime + 10))
    }
}

extension CustomPlayerViewController: KinescopeVideoPlayerDelegate {
    func playerDidLoadVideo(error: Error?) {
        guard error == nil else { return }
        applyLoadedOptions()
    }

    func player(changedItemStatusTo status: AVPlayerItem.Status) {
        guard status == .readyToPlay else { return }
        applyLoadedOptions()
    }

    func player(changedTimeControlStatusTo status: AVPlayer.TimeControlStatus) {
        playingNow = status == .playing
    }

    private func applyLoadedOptions() {
        guard !appliedPlayback, let player else { return }
        appliedPlayback = true
        player.setPreload(preload)
        if quality != "auto" {
            player.selectQuality(named: quality)
        }
        if warmMuted {
            warmMuted = false
            player.pause()
            player.setVolume(muted ? 0 : 1)
        }
        if !playsinline {
            player.enterFullscreen()
        }
    }
}

private struct PlayerTemplate {
    let id: String
    let name: String
    let settings: PlayerSettings?
}

private struct PlayerSettings {
    let autoplay: Bool?
    let muted: Bool?
    let loop: Bool?
    let controls: Bool?
    let playsinline: Bool?
    let preload: String?
    let quality: String?
    let keyboardShortcuts: Bool?
    let pictureInPicture: Bool?
    let fullscreen: Bool?
    let playbackRate: Bool?
    let color: String?
}
