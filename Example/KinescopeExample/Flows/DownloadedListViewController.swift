import UIKit
import KinescopeSDK

/// Saved videos, same screen as Android Offline DRM: downloaded rows, empty state, and a separate download screen.
final class DownloadedListViewController: UIViewController {

    private struct Item {
        let id: String
        var title: String
        var posterURL: URL?
        var progress: Double?
    }

    private var items: [Item] = []
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyLabel = UILabel()
    private let posterCache = NSCache<NSURL, UIImage>()
    private let surface = UIColor(white: 17.0 / 255.0, alpha: 1)

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = surface
        navigationController?.setNavigationBarHidden(true, animated: false)
        installHeader()
        installList()
        Kinescope.shared.videoDownloader.add(delegate: self)
        reloadSaved()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        reloadSaved()
    }

    deinit {
        Kinescope.shared.videoDownloader.remove(delegate: self)
    }

    private func installHeader() {
        let back = UIButton(type: .system)
        back.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        back.tintColor = .white
        back.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        let title = UILabel()
        title.text = "Saved videos"
        title.textColor = .white
        title.font = .systemFont(ofSize: 16, weight: .bold)
        let header = UIView()
        header.translatesAutoresizingMaskIntoConstraints = false
        back.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(back)
        header.addSubview(title)
        view.addSubview(header)
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 52),
            back.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 8),
            back.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            back.widthAnchor.constraint(equalToConstant: 40),
            back.heightAnchor.constraint(equalToConstant: 40),
            title.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            title.centerYAnchor.constraint(equalTo: header.centerYAnchor)
        ])
        header.tag = 1
    }

    private func installList() {
        tableView.backgroundColor = surface
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 80
        tableView.contentInset.bottom = 88
        tableView.register(SavedVideoCell.self, forCellReuseIdentifier: SavedVideoCell.reuseID)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = "No saved videos. Tap + to download."
        emptyLabel.textColor = UIColor.white.withAlphaComponent(0.64)
        emptyLabel.font = .systemFont(ofSize: 16)
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        let add = UIButton(type: .system)
        add.backgroundColor = UIColor(red: 97 / 255, green: 97 / 255, blue: 252 / 255, alpha: 1)
        add.tintColor = .white
        add.setImage(UIImage(systemName: "plus"), for: .normal)
        add.layer.cornerRadius = 28
        add.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        add.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        view.addSubview(add)
        let header = view.viewWithTag(1)!
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: header.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            add.widthAnchor.constraint(equalToConstant: 56),
            add.heightAnchor.constraint(equalToConstant: 56),
            add.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            add.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    private func reloadSaved() {
        let ids = Kinescope.shared.videoDownloader.downloadedList()
        let active = items.filter { $0.progress != nil && !ids.contains($0.id) }
        var next = active
        for id in ids where !next.contains(where: { $0.id == id }) {
            let previous = items.first(where: { $0.id == id })
            let poster = Kinescope.shared.videoDownloader.posterLocation(by: id) ?? previous?.posterURL
            next.append(Item(id: id, title: previous?.title ?? id, posterURL: poster, progress: nil))
        }
        items = next
        emptyLabel.isHidden = !items.isEmpty
        tableView.reloadData()
        fillMetadata()
    }

    private func fillMetadata() {
        KinescopeDashboard.videos { [weak self] result in
            guard let self, case .success(let videos) = result else { return }
            for index in self.items.indices {
                guard let match = videos.first(where: { $0.id == self.items[index].id }) else { continue }
                self.items[index].title = match.title
                let local = Kinescope.shared.videoDownloader.posterLocation(by: self.items[index].id)
                self.items[index].posterURL = local ?? match.posterURL
            }
            self.tableView.reloadData()
        }
    }

    @objc private func closeTapped() {
        if let navigation = navigationController, navigation.viewControllers.first !== self {
            navigation.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    @objc private func addTapped() {
        navigationController?.pushViewController(AddDownloadViewController(), animated: true)
    }

    private func play(_ item: Item) {
        guard item.progress == nil else {
            toast("Дождитесь окончания загрузки")
            return
        }
        guard let url = Kinescope.shared.videoDownloader.getLocation(by: item.id) else {
            toast("Файл не найден")
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let player = storyboard.instantiateViewController(withIdentifier: "VideoViewController") as? VideoViewController else {
            return
        }
        player.videoId = item.id
        player.localVideoURL = url
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.pushViewController(player, animated: true)
    }

    private func delete(_ id: String) {
        let removed = Kinescope.shared.videoDownloader.delete(videoId: id)
        // Rebuild from storage so the row cannot reappear with stale state.
        reloadSaved()
        toast(removed ? "Видео удалено" : "Не удалось удалить")
    }

    private func toast(_ text: String) {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        label.backgroundColor = UIColor(white: 0.15, alpha: 0.94)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -88),
            label.heightAnchor.constraint(equalToConstant: 36),
            label.widthAnchor.constraint(greaterThanOrEqualToConstant: 160)
        ])
        UIView.animate(withDuration: 0.25, delay: 1.4, options: []) {
            label.alpha = 0
        } completion: { _ in
            label.removeFromSuperview()
        }
    }
}

extension DownloadedListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SavedVideoCell.reuseID, for: indexPath) as! SavedVideoCell
        let item = items[indexPath.row]
        cell.apply(index: indexPath.row + 1,
                   title: item.title,
                   posterURL: item.posterURL,
                   progress: item.progress,
                   poster: posterCache)
        cell.onDelete = { [weak self] in self?.delete(item.id) }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        play(items[indexPath.row])
    }
}

extension DownloadedListViewController: KinescopeVideoDownloadableDelegate {
    func videoDownloadProgress(videoId: String, progress value: Double) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if let index = self.items.firstIndex(where: { $0.id == videoId }) {
                self.items[index].progress = value
            } else {
                self.items.insert(Item(id: videoId, title: videoId, posterURL: nil, progress: value), at: 0)
                self.emptyLabel.isHidden = true
            }
            self.tableView.reloadData()
        }
    }

    func videoDownloadError(videoId: String, error: KinescopeDownloadError) {
        DispatchQueue.main.async { [weak self] in
            self?.items.removeAll { $0.id == videoId && $0.progress != nil }
            self?.reloadSaved()
            self?.toast(error.localizedDescription)
        }
    }

    func videoDownloadComplete(videoId: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if let index = self.items.firstIndex(where: { $0.id == videoId }) {
                self.items[index].progress = nil
            }
            self.reloadSaved()
        }
    }
}

/// Separate download screen, same as Android "Скачать видео": id field and the dashboard catalog.
final class AddDownloadViewController: UIViewController {

    private var videos: [KinescopeLibraryVideo] = []
    private var progress: [String: Double] = [:]
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let idField = UITextField()

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        navigationController?.setNavigationBarHidden(true, animated: false)
        installChrome()
        Kinescope.shared.videoDownloader.add(delegate: self)
        KinescopeDashboard.videos { [weak self] result in
            guard let self else { return }
            if case .success(let videos) = result {
                self.videos = videos
                self.tableView.reloadData()
            }
            if self.videos.isEmpty {
                self.toast("Нет видео для скачивания")
            }
        }
    }

    deinit {
        Kinescope.shared.videoDownloader.remove(delegate: self)
    }

    private func installChrome() {
        let back = UIButton(type: .system)
        back.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        back.tintColor = .white
        back.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        let title = UILabel()
        title.text = "Скачать видео"
        title.textColor = .white
        title.font = .systemFont(ofSize: 18, weight: .bold)
        let header = UIView()
        header.translatesAutoresizingMaskIntoConstraints = false
        back.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)
        header.addSubview(back)
        header.addSubview(title)

        idField.attributedPlaceholder = NSAttributedString(string: "Video ID (DRM)",
                                                           attributes: [.foregroundColor: UIColor.gray])
        idField.textColor = .white
        idField.font = .systemFont(ofSize: 14)
        idField.autocorrectionType = .no
        idField.autocapitalizationType = .none
        idField.borderStyle = .none
        let download = UIButton(type: .system)
        download.setTitle("Скачать", for: .normal)
        download.setTitleColor(.white, for: .normal)
        download.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        download.backgroundColor = UIColor(red: 97 / 255, green: 97 / 255, blue: 252 / 255, alpha: 1)
        download.layer.cornerRadius = 8
        download.addTarget(self, action: #selector(downloadById), for: .touchUpInside)
        let fieldRow = UIStackView(arrangedSubviews: [idField, download])
        fieldRow.axis = .horizontal
        fieldRow.spacing = 8
        fieldRow.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fieldRow)

        tableView.backgroundColor = .black
        tableView.separatorColor = UIColor.white.withAlphaComponent(0.12)
        tableView.dataSource = self
        tableView.rowHeight = 76
        tableView.register(DownloadCatalogCell.self, forCellReuseIdentifier: DownloadCatalogCell.reuseID)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 52),
            back.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 8),
            back.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            back.widthAnchor.constraint(equalToConstant: 40),
            back.heightAnchor.constraint(equalToConstant: 40),
            title.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            title.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            download.widthAnchor.constraint(equalToConstant: 96),
            download.heightAnchor.constraint(equalToConstant: 36),
            fieldRow.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 8),
            fieldRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            fieldRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: fieldRow.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func closeTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func downloadById() {
        let videoId = idField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !videoId.isEmpty else {
            toast("Введите Video ID")
            return
        }
        view.endEditing(true)
        Kinescope.shared.inspector.video(id: videoId, onSuccess: { [weak self] video in
            self?.promptQuality(for: video)
        }, onError: { [weak self] error in
            self?.toast(error.localizedDescription)
        })
    }

    private func promptQuality(for video: KinescopeVideo) {
        KinescopeOffline.qualities(for: video) { [weak self] qualities in
            guard let self else { return }
            guard !qualities.isEmpty else {
                self.toast("Нет доступных качеств")
                return
            }
            guard qualities.count > 1 else {
                self.startDownload(video, height: qualities.first?.height)
                return
            }
            let sheet = UIAlertController(title: "Качество: \(video.title)", message: nil, preferredStyle: .actionSheet)
            for quality in qualities {
                sheet.addAction(UIAlertAction(title: quality.name, style: .default) { [weak self] _ in
                    self?.startDownload(video, height: quality.height)
                })
            }
            sheet.addAction(UIAlertAction(title: "Отмена", style: .cancel))
            sheet.popoverPresentationController?.sourceView = self.view
            self.present(sheet, animated: true)
        }
    }

    private func startDownload(_ video: KinescopeVideo, height: Int?) {
        guard let url = URL(string: video.hlsLink) else {
            toast("Нет ссылки на видео")
            return
        }
        progress[video.id] = 0
        tableView.reloadData()
        Kinescope.shared.videoDownloader.enqueueDownload(videoId: video.id,
                                                         url: url,
                                                         video: video,
                                                         minimumHeight: height)
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
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
        UIView.animate(withDuration: 0.25, delay: 1.6, options: []) {
            label.alpha = 0
        } completion: { _ in
            label.removeFromSuperview()
        }
    }
}

extension AddDownloadViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        videos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DownloadCatalogCell.reuseID, for: indexPath) as! DownloadCatalogCell
        let video = videos[indexPath.row]
        cell.apply(title: video.title, progress: progress[video.id])
        cell.onDownload = { [weak self] in
            Kinescope.shared.inspector.video(id: video.id, onSuccess: { video in
                self?.promptQuality(for: video)
            }, onError: { error in
                self?.toast(error.localizedDescription)
            })
        }
        return cell
    }
}

extension AddDownloadViewController: KinescopeVideoDownloadableDelegate {
    func videoDownloadProgress(videoId: String, progress value: Double) {
        DispatchQueue.main.async { [weak self] in
            self?.progress[videoId] = value
            self?.tableView.reloadData()
        }
    }

    func videoDownloadError(videoId: String, error: KinescopeDownloadError) {
        DispatchQueue.main.async { [weak self] in
            self?.progress[videoId] = nil
            self?.tableView.reloadData()
            self?.toast("Ошибка скачивания")
        }
    }

    func videoDownloadComplete(videoId: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.progress[videoId] = nil
            self.tableView.reloadData()
            let title = self.videos.first(where: { $0.id == videoId })?.title ?? ""
            self.toast(title.isEmpty ? "Видео скачано" : "Видео \"\(title)\" скачано")
        }
    }
}

private final class SavedVideoCell: UITableViewCell {
    static let reuseID = "SavedVideoCell"
    var onDelete: (() -> Void)?
    private let indexLabel = UILabel()
    private let posterView = UIImageView()
    private let playView = UIImageView(image: UIImage(systemName: "play.fill"))
    private let titleLabel = UILabel()
    private let bar = UIProgressView(progressViewStyle: .bar)
    private let progressLabel = UILabel()
    private var posterTask: URLSessionDataTask?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(white: 17.0 / 255.0, alpha: 1)
        contentView.backgroundColor = backgroundColor
        selectionStyle = .none
        indexLabel.font = .systemFont(ofSize: 14)
        indexLabel.textColor = UIColor.white.withAlphaComponent(0.64)
        indexLabel.textAlignment = .right
        posterView.contentMode = .scaleAspectFill
        posterView.clipsToBounds = true
        posterView.layer.cornerRadius = 4
        posterView.backgroundColor = UIColor.white.withAlphaComponent(31.0 / 255.0)
        playView.tintColor = .white
        playView.contentMode = .scaleAspectFit
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.numberOfLines = 2
        bar.progressTintColor = UIColor(red: 97 / 255, green: 97 / 255, blue: 252 / 255, alpha: 1)
        bar.trackTintColor = UIColor.white.withAlphaComponent(0.16)
        progressLabel.font = .systemFont(ofSize: 12)
        progressLabel.textColor = UIColor.white.withAlphaComponent(0.64)
        let trash = UIButton(type: .system)
        trash.setImage(UIImage(systemName: "trash"), for: .normal)
        trash.tintColor = .white
        trash.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        let thumb = UIView()
        thumb.addSubview(posterView)
        thumb.addSubview(playView)
        posterView.translatesAutoresizingMaskIntoConstraints = false
        playView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            posterView.topAnchor.constraint(equalTo: thumb.topAnchor),
            posterView.leadingAnchor.constraint(equalTo: thumb.leadingAnchor),
            posterView.trailingAnchor.constraint(equalTo: thumb.trailingAnchor),
            posterView.bottomAnchor.constraint(equalTo: thumb.bottomAnchor),
            playView.centerXAnchor.constraint(equalTo: thumb.centerXAnchor),
            playView.centerYAnchor.constraint(equalTo: thumb.centerYAnchor),
            playView.widthAnchor.constraint(equalToConstant: 16),
            playView.heightAnchor.constraint(equalToConstant: 16),
            thumb.widthAnchor.constraint(equalToConstant: 32),
            thumb.heightAnchor.constraint(equalToConstant: 56)
        ])
        let texts = UIStackView(arrangedSubviews: [titleLabel, bar, progressLabel])
        texts.axis = .vertical
        texts.spacing = 4
        let row = UIStackView(arrangedSubviews: [indexLabel, thumb, texts, trash])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        row.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(row)
        NSLayoutConstraint.activate([
            indexLabel.widthAnchor.constraint(equalToConstant: 24),
            trash.widthAnchor.constraint(equalToConstant: 24),
            trash.heightAnchor.constraint(equalToConstant: 24),
            bar.heightAnchor.constraint(equalToConstant: 4),
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func apply(index: Int, title: String, posterURL: URL?, progress: Double?, poster cache: NSCache<NSURL, UIImage>) {
        indexLabel.text = "\(index)"
        titleLabel.text = title
        let active = progress != nil
        playView.isHidden = active
        bar.isHidden = !active
        progressLabel.isHidden = !active
        if let progress {
            bar.progress = Float(min(1, progress / 100))
            progressLabel.text = String(format: "Скачивается: %.0f%%", progress)
        }
        posterTask?.cancel()
        posterView.image = nil
        guard let url = posterURL else { return }
        if url.isFileURL {
            posterView.image = UIImage(contentsOfFile: url.path)
            return
        }
        if let image = cache.object(forKey: url as NSURL) {
            posterView.image = image
            return
        }
        posterView.accessibilityIdentifier = url.absoluteString
        posterTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            cache.setObject(image, forKey: url as NSURL)
            DispatchQueue.main.async {
                guard self?.posterView.accessibilityIdentifier == url.absoluteString else { return }
                self?.posterView.image = image
            }
        }
        posterTask?.resume()
    }

    @objc private func deleteTapped() { onDelete?() }
}

private final class DownloadCatalogCell: UITableViewCell {
    static let reuseID = "DownloadCatalogCell"
    var onDownload: (() -> Void)?
    private let titleLabel = UILabel()
    private let bar = UIProgressView(progressViewStyle: .bar)
    private let progressLabel = UILabel()
    private let button = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .black
        selectionStyle = .none
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.numberOfLines = 2
        bar.progressTintColor = UIColor(red: 97 / 255, green: 97 / 255, blue: 252 / 255, alpha: 1)
        bar.trackTintColor = UIColor.white.withAlphaComponent(0.16)
        progressLabel.font = .systemFont(ofSize: 12)
        progressLabel.textColor = .gray
        button.setTitle("Скачать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        let texts = UIStackView(arrangedSubviews: [titleLabel, bar, progressLabel])
        texts.axis = .vertical
        texts.spacing = 4
        let row = UIStackView(arrangedSubviews: [texts, button])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        row.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(row)
        NSLayoutConstraint.activate([
            bar.heightAnchor.constraint(equalToConstant: 4),
            button.widthAnchor.constraint(equalToConstant: 88),
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func apply(title: String, progress: Double?) {
        titleLabel.text = title
        let active = progress != nil
        bar.isHidden = !active
        progressLabel.isHidden = !active
        button.isEnabled = !active
        if let progress {
            bar.progress = Float(min(1, progress / 100))
            progressLabel.text = String(format: "%.0f%%", progress)
            button.setTitle("…", for: .normal)
        } else {
            button.setTitle("Скачать", for: .normal)
        }
    }

    @objc private func tapped() { onDownload?() }
}
