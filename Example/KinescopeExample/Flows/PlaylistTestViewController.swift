import UIKit
import KinescopeSDK

/// Same screen as the Android Playlist test: player on top, light list of every dashboard video below.
final class PlaylistTestViewController: UIViewController {

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    private let playerHost = KinescopePlayerView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let progressLabel = UILabel()
    private var videos: [KinescopeLibraryVideo] = []
    private var selectedId: String?
    private var player: KinescopeVideoPlayer?
    private var didInstallChrome = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 245.0 / 255.0, alpha: 1)
        installPlayer()
        installPanel()
        loadVideos()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async { [weak self] in
            self?.ensureChrome()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        if isMovingFromParent || isBeingDismissed {
            releasePlayer()
        }
    }

    private func installPlayer() {
        playerHost.backgroundColor = .black
        playerHost.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playerHost)
        NSLayoutConstraint.activate([
            playerHost.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            playerHost.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerHost.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerHost.heightAnchor.constraint(equalToConstant: 211)
        ])
    }

    private func installPanel() {
        let panel = UIView()
        panel.backgroundColor = .white
        panel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(panel)

        let border = UIView()
        border.backgroundColor = UIColor(white: 17.0 / 255.0, alpha: 0.08)
        border.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(border)

        let handle = UIView()
        handle.backgroundColor = UIColor(white: 17.0 / 255.0, alpha: 0.16)
        handle.layer.cornerRadius = 2
        handle.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(handle)

        let title = UILabel()
        title.text = "Playlist"
        title.font = .systemFont(ofSize: 16, weight: .medium)
        title.textColor = UIColor(white: 17.0 / 255.0, alpha: 1)

        progressLabel.font = .systemFont(ofSize: 12)
        progressLabel.textColor = UIColor(white: 17.0 / 255.0, alpha: 0.64)

        let titles = UIStackView(arrangedSubviews: [title, progressLabel])
        titles.axis = .vertical
        titles.spacing = 4

        let close = UIButton(type: .system)
        close.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        close.tintColor = UIColor(white: 17.0 / 255.0, alpha: 1)
        close.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        let header = UIStackView(arrangedSubviews: [close, titles])
        header.axis = .horizontal
        header.alignment = .center
        header.spacing = 8
        header.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(header)

        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 80
        tableView.register(PlaylistCatalogCell.self, forCellReuseIdentifier: PlaylistCatalogCell.reuseID)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(tableView)

        NSLayoutConstraint.activate([
            panel.topAnchor.constraint(equalTo: playerHost.bottomAnchor),
            panel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            panel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            panel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            border.topAnchor.constraint(equalTo: panel.topAnchor),
            border.leadingAnchor.constraint(equalTo: panel.leadingAnchor),
            border.trailingAnchor.constraint(equalTo: panel.trailingAnchor),
            border.heightAnchor.constraint(equalToConstant: 1),
            handle.topAnchor.constraint(equalTo: panel.topAnchor, constant: 3),
            handle.centerXAnchor.constraint(equalTo: panel.centerXAnchor),
            handle.widthAnchor.constraint(equalToConstant: 32),
            handle.heightAnchor.constraint(equalToConstant: 4),
            close.widthAnchor.constraint(equalToConstant: 40),
            close.heightAnchor.constraint(equalToConstant: 40),
            header.topAnchor.constraint(equalTo: panel.topAnchor, constant: 16),
            header.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 16),
            header.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: panel.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: panel.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: panel.bottomAnchor)
        ])
    }

    private func loadVideos() {
        KinescopeDashboard.videos(projectId: KinescopeDemoConfig.projectId,
                                  folderId: KinescopeDemoConfig.folderId) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let videos):
                self.videos = videos
                self.tableView.reloadData()
            case .failure:
                self.progressLabel.text = ""
            }
        }
    }

    /// Builds the player chrome before the screen is shown. The menu calls this while it is idle.
    func prepareForOpen() {
        loadViewIfNeeded()
        view.frame = UIScreen.main.bounds
        view.layoutIfNeeded()
        ensureChrome()
    }

    private func ensureChrome() {
        guard !didInstallChrome else { return }
        didInstallChrome = true
        playerHost.setLayout(with: .default)
    }

    private func play(_ videoId: String) {
        ensureChrome()
        guard selectedId != videoId || player == nil else { return }
        let previous = selectedId
        selectedId = videoId
        updateProgress()
        var rows: [IndexPath] = []
        if let old = videos.firstIndex(where: { $0.id == previous }) {
            rows.append(IndexPath(row: old, section: 0))
        }
        if let new = videos.firstIndex(where: { $0.id == videoId }), !rows.contains(IndexPath(row: new, section: 0)) {
            rows.append(IndexPath(row: new, section: 0))
        }
        if !rows.isEmpty {
            tableView.reloadRows(at: rows, with: .none)
        }
        releasePlayer()
        let next = KinescopeVideoPlayer(config: .init(videoId: videoId))
        next.attach(view: playerHost)
        next.play()
        player = next
        if let row = videos.firstIndex(where: { $0.id == videoId }) {
            let path = IndexPath(row: row, section: 0)
            if tableView.indexPathsForVisibleRows?.contains(path) != true {
                tableView.scrollToRow(at: path, at: .none, animated: false)
            }
        }
    }

    private func updateProgress() {
        guard let selectedId, let index = videos.firstIndex(where: { $0.id == selectedId }) else {
            progressLabel.text = ""
            return
        }
        progressLabel.text = "\(index + 1) of \(videos.count) videos"
    }

    private func releasePlayer() {
        player?.pause()
        player?.stop()
        player?.detach(view: playerHost)
        player = nil
    }

    @objc private func closeTapped() {
        navigationController?.popViewController(animated: true)
    }

    fileprivate static func sdkImage(_ name: String) -> UIImage {
        let framework = Bundle(for: KinescopePlayerView.self)
        let nested = framework.path(forResource: "KinescopeSDK", ofType: "bundle").flatMap(Bundle.init(path:))
        return UIImage(named: name, in: nested ?? framework, compatibleWith: nil) ?? UIImage()
    }

    private func copyLink(for video: KinescopeLibraryVideo) {
        UIPasteboard.general.string = "https://kinescope.io/\(video.id)"
        let toast = UILabel()
        toast.text = "Link copied"
        toast.textColor = .white
        toast.font = .systemFont(ofSize: 14)
        toast.backgroundColor = UIColor(white: 0.1, alpha: 0.92)
        toast.textAlignment = .center
        toast.layer.cornerRadius = 8
        toast.clipsToBounds = true
        toast.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toast)
        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            toast.heightAnchor.constraint(equalToConstant: 36),
            toast.widthAnchor.constraint(greaterThanOrEqualToConstant: 140)
        ])
        UIView.animate(withDuration: 0.25, delay: 1.2, options: []) {
            toast.alpha = 0
        } completion: { _ in
            toast.removeFromSuperview()
        }
    }
}

extension PlaylistTestViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        videos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistCatalogCell.reuseID, for: indexPath) as! PlaylistCatalogCell
        let video = videos[indexPath.row]
        cell.apply(video: video, index: indexPath.row + 1, selected: video.id == selectedId)
        cell.onCopy = { [weak self] in
            self?.copyLink(for: video)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        play(videos[indexPath.row].id)
    }
}

private final class PlaylistCatalogCell: UITableViewCell {
    static let reuseID = "PlaylistCatalogCell"
    var onCopy: (() -> Void)?

    private let indexLabel = UILabel()
    private let playingView = UIImageView()
    private let posterView = UIImageView()
    private let durationLabel = UILabel()
    private let titleLabel = UILabel()
    private var posterTask: URLSessionDataTask?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        selectionStyle = .none
        let ink = UIColor(white: 17.0 / 255.0, alpha: 1)
        let secondary = UIColor(white: 17.0 / 255.0, alpha: 0.64)

        indexLabel.font = .systemFont(ofSize: 14)
        indexLabel.textColor = secondary
        indexLabel.textAlignment = .center
        playingView.image = PlaylistTestViewController.sdkImage("playlistPlaying").withRenderingMode(.alwaysTemplate)
        playingView.tintColor = ink
        playingView.contentMode = .scaleAspectFit

        posterView.contentMode = .scaleAspectFill
        posterView.clipsToBounds = true
        posterView.layer.cornerRadius = 4
        posterView.backgroundColor = UIColor(white: 232.0 / 255.0, alpha: 1)

        durationLabel.font = .systemFont(ofSize: 12)
        durationLabel.textColor = .white
        durationLabel.backgroundColor = UIColor(white: 17.0 / 255.0, alpha: 0.64)
        durationLabel.layer.cornerRadius = 2
        durationLabel.clipsToBounds = true

        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = ink
        titleLabel.numberOfLines = 2

        let copy = UIButton(type: .system)
        copy.setImage(PlaylistTestViewController.sdkImage("copyLink").withRenderingMode(.alwaysTemplate), for: .normal)
        copy.tintColor = secondary
        copy.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)

        let mark = UIView()
        mark.addSubview(indexLabel)
        mark.addSubview(playingView)
        indexLabel.translatesAutoresizingMaskIntoConstraints = false
        playingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indexLabel.centerXAnchor.constraint(equalTo: mark.centerXAnchor),
            indexLabel.centerYAnchor.constraint(equalTo: mark.centerYAnchor),
            playingView.centerXAnchor.constraint(equalTo: mark.centerXAnchor),
            playingView.centerYAnchor.constraint(equalTo: mark.centerYAnchor),
            playingView.widthAnchor.constraint(equalToConstant: 16),
            playingView.heightAnchor.constraint(equalToConstant: 16),
            mark.widthAnchor.constraint(equalToConstant: 24),
            mark.heightAnchor.constraint(equalToConstant: 24)
        ])

        let thumb = UIView()
        thumb.addSubview(posterView)
        thumb.addSubview(durationLabel)
        posterView.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            posterView.topAnchor.constraint(equalTo: thumb.topAnchor),
            posterView.leadingAnchor.constraint(equalTo: thumb.leadingAnchor),
            posterView.trailingAnchor.constraint(equalTo: thumb.trailingAnchor),
            posterView.bottomAnchor.constraint(equalTo: thumb.bottomAnchor),
            durationLabel.trailingAnchor.constraint(equalTo: thumb.trailingAnchor, constant: -4),
            durationLabel.bottomAnchor.constraint(equalTo: thumb.bottomAnchor, constant: -4),
            thumb.widthAnchor.constraint(equalToConstant: 100),
            thumb.heightAnchor.constraint(equalToConstant: 56)
        ])

        let row = UIStackView(arrangedSubviews: [mark, thumb, titleLabel, copy])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        row.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(row)
        NSLayoutConstraint.activate([
            copy.widthAnchor.constraint(equalToConstant: 24),
            copy.heightAnchor.constraint(equalToConstant: 24),
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(video: KinescopeLibraryVideo, index: Int, selected: Bool) {
        indexLabel.text = "\(index)"
        indexLabel.isHidden = selected
        playingView.isHidden = !selected
        titleLabel.text = video.title
        contentView.backgroundColor = selected ? UIColor(white: 17.0 / 255.0, alpha: 0.04) : .white
        if let duration = Self.clock(video.duration) {
            durationLabel.text = " \(duration) "
            durationLabel.isHidden = false
        } else {
            durationLabel.isHidden = true
        }
        posterTask?.cancel()
        posterView.image = nil
        posterView.accessibilityIdentifier = video.posterURL?.absoluteString
        if let url = video.posterURL {
            posterTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    guard self?.posterView.accessibilityIdentifier == url.absoluteString else { return }
                    self?.posterView.image = image
                }
            }
            posterTask?.resume()
        }
    }

    @objc private func copyTapped() {
        onCopy?()
    }

    private static func clock(_ seconds: TimeInterval?) -> String? {
        guard let seconds, seconds > 0 else { return nil }
        let total = Int(seconds)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let secs = total % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        }
        return String(format: "%d:%02d", minutes, secs)
    }
}
