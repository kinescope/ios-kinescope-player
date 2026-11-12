import UIKit

/// Bottom playlist sheet: index or playing mark, poster, duration, title. Same layout as Android.
final class PlaylistSheetView: UIView {

    var onSelect: ((KinescopePlaylistItem) -> Void)?
    var onCopy: ((KinescopePlaylistItem) -> Void)?

    private let panel = UIView()
    private let titleLabel = UILabel()
    private let countLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var items: [KinescopePlaylistItem] = []
    private var selectedId: String?
    private var listHeight: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
        backgroundColor = .clear

        panel.backgroundColor = UIColor(white: 17.0 / 255.0, alpha: 1)
        panel.layer.cornerRadius = 6
        panel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        panel.clipsToBounds = true
        addSubview(panel)
        panel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = L10n.Player.playlist
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .white
        countLabel.font = .systemFont(ofSize: 14)
        countLabel.textColor = UIColor.white.withAlphaComponent(0.64)

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 80
        tableView.register(PlaylistRowCell.self, forCellReuseIdentifier: PlaylistRowCell.reuseID)

        let header = UIView()
        header.addSubview(titleLabel)
        header.addSubview(countLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(header)
        panel.addSubview(tableView)
        header.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let height = tableView.heightAnchor.constraint(equalToConstant: 0)
        listHeight = height
        NSLayoutConstraint.activate([
            panel.leadingAnchor.constraint(equalTo: leadingAnchor),
            panel.trailingAnchor.constraint(equalTo: trailingAnchor),
            panel.bottomAnchor.constraint(equalTo: bottomAnchor),
            header.topAnchor.constraint(equalTo: panel.topAnchor, constant: 8),
            header.leadingAnchor.constraint(equalTo: panel.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: panel.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 36),
            titleLabel.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            countLabel.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16),
            countLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            tableView.topAnchor.constraint(equalTo: header.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: panel.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: panel.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: panel.bottomAnchor),
            height
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:)))
        tap.delegate = self
        addGestureRecognizer(tap)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func preload(items: [KinescopePlaylistItem], selectedId: String?) {
        guard self.items.map(\.id) != items.map(\.id) || self.selectedId != selectedId else {
            return
        }
        applyList(items, selectedId: selectedId)
        tableView.layoutIfNeeded()
    }

    func show(items: [KinescopePlaylistItem], selectedId: String?) {
        if self.items.map(\.id) != items.map(\.id) || self.selectedId != selectedId {
            applyList(items, selectedId: selectedId)
        }
        let travel = (listHeight?.constant ?? 0) + 44
        isHidden = false
        panel.transform = CGAffineTransform(translationX: 0, y: travel + 24)
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            self.panel.transform = .identity
        }
        if let row = items.firstIndex(where: { $0.id == selectedId }), items.indices.contains(row) {
            tableView.scrollToRow(at: IndexPath(row: row, section: 0), at: .middle, animated: false)
        }
    }

    private func applyList(_ items: [KinescopePlaylistItem], selectedId: String?) {
        self.items = items
        self.selectedId = selectedId
        countLabel.text = L10n.Player.playlistCount(items.count)
        listHeight?.constant = min(420, CGFloat(items.count) * 80)
        tableView.reloadData()
    }

    func dismiss() {
        UIView.animate(withDuration: 0.2, animations: {
            self.panel.transform = CGAffineTransform(translationX: 0, y: self.panel.bounds.height)
        }, completion: { _ in
            self.isHidden = true
            self.panel.transform = .identity
        })
    }

    @objc private func backgroundTapped(_ recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: self)
        if !panel.frame.contains(point) {
            dismiss()
        }
    }
}

extension PlaylistSheetView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        !(touch.view?.isDescendant(of: panel) ?? false)
    }
}

extension PlaylistSheetView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistRowCell.reuseID, for: indexPath) as! PlaylistRowCell
        let item = items[indexPath.row]
        cell.apply(item: item, index: indexPath.row + 1, selected: item.id == selectedId)
        cell.onCopy = { [weak self] in
            self?.onCopy?(item)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = items[indexPath.row]
        dismiss()
        onSelect?(item)
    }
}

private final class PlaylistRowCell: UITableViewCell {
    static let reuseID = "PlaylistRowCell"
    var onCopy: (() -> Void)?

    private let indexLabel = UILabel()
    private let playingView = UIImageView()
    private let posterView = UIImageView()
    private let durationLabel = UILabel()
    private let titleLabel = UILabel()
    private let copyButton = UIButton(type: .system)
    private var posterTask: URLSessionDataTask?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        let selected = UIView()
        selected.backgroundColor = UIColor.white.withAlphaComponent(0.04)
        selectedBackgroundView = selected

        indexLabel.font = .systemFont(ofSize: 14)
        indexLabel.textColor = UIColor.white.withAlphaComponent(0.64)
        indexLabel.textAlignment = .center
        playingView.image = .image(named: "playlistPlaying")
        playingView.contentMode = .scaleAspectFit
        playingView.tintColor = .white

        posterView.contentMode = .scaleAspectFill
        posterView.clipsToBounds = true
        posterView.layer.cornerRadius = 4
        posterView.backgroundColor = UIColor.white.withAlphaComponent(26.0 / 255.0)

        durationLabel.font = .systemFont(ofSize: 12)
        durationLabel.textColor = .white
        durationLabel.backgroundColor = UIColor(white: 17.0 / 255.0, alpha: 0.8)
        durationLabel.layer.cornerRadius = 2
        durationLabel.clipsToBounds = true

        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2

        copyButton.setImage(.image(named: "copyLink").withRenderingMode(.alwaysTemplate), for: .normal)
        copyButton.tintColor = .white
        copyButton.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)

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

        let row = UIStackView(arrangedSubviews: [mark, thumb, titleLabel, copyButton])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        row.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(row)
        NSLayoutConstraint.activate([
            copyButton.widthAnchor.constraint(equalToConstant: 24),
            copyButton.heightAnchor.constraint(equalToConstant: 24),
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        contentView.backgroundColor = selected ? UIColor.white.withAlphaComponent(0.04) : .clear
    }

    func apply(item: KinescopePlaylistItem, index: Int, selected: Bool) {
        indexLabel.text = "\(index)"
        indexLabel.isHidden = selected
        playingView.isHidden = !selected
        titleLabel.text = item.title
        contentView.backgroundColor = selected ? UIColor.white.withAlphaComponent(0.04) : .clear
        if let duration = Self.clock(item.durationSeconds) {
            durationLabel.text = " \(duration) "
            durationLabel.isHidden = false
        } else {
            durationLabel.isHidden = true
        }
        copyButton.isHidden = !(selected && !(item.shareUrl ?? "").isEmpty)
        posterTask?.cancel()
        posterView.image = nil
        posterView.accessibilityIdentifier = item.posterUrl
        if let raw = item.posterUrl, let url = URL(string: raw) {
            posterTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    guard self?.posterView.accessibilityIdentifier == raw else { return }
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
