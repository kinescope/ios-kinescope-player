import UIKit

/// Full-player caption list. Choosing a line seeks and keeps the list open, with that line highlighted.
final class CaptionsSearchView: UIView {

    var onSeek: ((TimeInterval) -> Void)?
    var onDismiss: (() -> Void)?

    private let field = UITextField()
    private let counterLabel = UILabel()
    private let previousButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var cues: [SubtitleCue] = []
    private var matches: [Int] = []
    private var matchIndex = 0
    private var focusedIndex = -1
    private var playingIndex = -1
    private var followPlayback = true
    private var loadedWidth: CGFloat = -1
    private var widthRefreshScheduled = false

    private static let highlight = UIColor(red: 232.0 / 255.0, green: 93.0 / 255.0, blue: 4.0 / 255.0, alpha: 1)

    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
        backgroundColor = UIColor.black.withAlphaComponent(0.96)

        let input = UIView()
        input.backgroundColor = UIColor.white.withAlphaComponent(0.16)
        input.layer.cornerRadius = 6
        input.layer.borderWidth = 1
        input.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor

        let icon = UIImageView(image: .image(named: "search").withRenderingMode(.alwaysTemplate))
        icon.tintColor = .white
        icon.contentMode = .scaleAspectFit
        field.textColor = .white
        field.tintColor = .white
        field.font = .systemFont(ofSize: 14)
        field.attributedPlaceholder = NSAttributedString(
            string: L10n.Player.subtitleSearch,
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.64)]
        )
        field.autocorrectionType = .no
        field.returnKeyType = .search
        field.addTarget(self, action: #selector(queryChanged), for: .editingChanged)
        counterLabel.font = .systemFont(ofSize: 14)
        counterLabel.textColor = UIColor.white.withAlphaComponent(0.64)
        counterLabel.setContentHuggingPriority(.required, for: .horizontal)

        previousButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        nextButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        previousButton.tintColor = .white
        nextButton.tintColor = .white
        previousButton.addTarget(self, action: #selector(previousMatch), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextMatch), for: .touchUpInside)

        let close = UIButton(type: .system)
        close.setImage(.image(named: "close").withRenderingMode(.alwaysTemplate), for: .normal)
        close.tintColor = .white
        close.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        let tools = UIStackView(arrangedSubviews: [icon, field, counterLabel, previousButton, nextButton])
        tools.axis = .horizontal
        tools.alignment = .center
        tools.spacing = 4
        input.addSubview(tools)
        tools.translatesAutoresizingMaskIntoConstraints = false

        let header = UIStackView(arrangedSubviews: [input, close])
        header.axis = .horizontal
        header.alignment = .center
        header.spacing = 8
        addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        tableView.register(CaptionLineCell.self, forCellReuseIdentifier: CaptionLineCell.reuseID)
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 24),
            icon.heightAnchor.constraint(equalToConstant: 24),
            previousButton.widthAnchor.constraint(equalToConstant: 24),
            previousButton.heightAnchor.constraint(equalToConstant: 24),
            nextButton.widthAnchor.constraint(equalToConstant: 24),
            nextButton.heightAnchor.constraint(equalToConstant: 24),
            close.widthAnchor.constraint(equalToConstant: 24),
            close.heightAnchor.constraint(equalToConstant: 24),
            input.heightAnchor.constraint(equalToConstant: 40),
            tools.leadingAnchor.constraint(equalTo: input.leadingAnchor, constant: 8),
            tools.trailingAnchor.constraint(equalTo: input.trailingAnchor, constant: -8),
            tools.topAnchor.constraint(equalTo: input.topAnchor),
            tools.bottomAnchor.constraint(equalTo: input.bottomAnchor),
            header.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            header.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            header.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let width = tableView.bounds.width
        guard !isHidden, width > 1, abs(width - loadedWidth) > 1, !widthRefreshScheduled else { return }
        widthRefreshScheduled = true
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.widthRefreshScheduled = false
            let width = self.tableView.bounds.width
            guard !self.isHidden, width > 1, abs(width - self.loadedWidth) > 1 else { return }
            self.loadedWidth = width
            self.tableView.reloadData()
            if self.followPlayback {
                self.scrollToPlaying(animated: false)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(cues: [SubtitleCue], time: TimeInterval) {
        self.cues = cues
        field.text = ""
        matches = []
        matchIndex = 0
        focusedIndex = -1
        followPlayback = true
        playingIndex = Self.index(at: time, in: cues)
        refreshNavigation()
        isHidden = false
        loadedWidth = -1
        superview?.layoutIfNeeded()
        loadedWidth = tableView.bounds.width
        tableView.reloadData()
        scrollToPlaying(animated: false)
    }

    func update(time: TimeInterval) {
        guard !isHidden else { return }
        let index = Self.index(at: time, in: cues)
        guard index != playingIndex else { return }
        playingIndex = index
        tableView.reloadData()
        if followPlayback {
            scrollToPlaying(animated: true)
        }
    }

    func dismiss() {
        field.resignFirstResponder()
        isHidden = true
        onDismiss?()
    }

    @objc private func closeTapped() {
        dismiss()
    }

    @objc private func queryChanged() {
        let query = field.text ?? ""
        matches = cues.indices.filter { index in
            guard !query.isEmpty else { return false }
            return cues[index].lines.joined(separator: " ").range(of: query, options: .caseInsensitive) != nil
        }
        matchIndex = matches.isEmpty ? 0 : min(matchIndex, matches.count - 1)
        refreshNavigation()
        tableView.reloadData()
    }

    @objc private func previousMatch() {
        step(-1)
    }

    @objc private func nextMatch() {
        step(1)
    }

    private func step(_ delta: Int) {
        guard !matches.isEmpty else { return }
        followPlayback = false
        matchIndex = (matchIndex + delta + matches.count) % matches.count
        focus(matches[matchIndex])
    }

    private func focus(_ index: Int) {
        focusedIndex = index
        followPlayback = false
        if let found = matches.firstIndex(of: index) {
            matchIndex = found
        }
        refreshNavigation()
        tableView.reloadData()
        onSeek?(cues[index].start)
        tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: true)
    }

    private func refreshNavigation() {
        let visible = !matches.isEmpty
        counterLabel.isHidden = !visible
        previousButton.isHidden = !visible
        nextButton.isHidden = !visible
        if visible {
            counterLabel.text = "\(matchIndex + 1)/\(matches.count)"
        }
    }

    private func scrollToPlaying(animated: Bool) {
        guard playingIndex >= 0, playingIndex < cues.count else { return }
        tableView.scrollToRow(at: IndexPath(row: playingIndex, section: 0), at: .middle, animated: animated)
    }

    private static func index(at time: TimeInterval, in cues: [SubtitleCue]) -> Int {
        cues.firstIndex { time >= $0.start && time < $0.end } ?? -1
    }
}

extension CaptionsSearchView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cues.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CaptionLineCell.reuseID, for: indexPath) as! CaptionLineCell
        let query = field.text ?? ""
        let active = matches.indices.contains(matchIndex) && matches[matchIndex] == indexPath.row
        let hasMatch = matches.contains(indexPath.row)
        let focused = indexPath.row == focusedIndex || (focusedIndex < 0 && active)
        cell.apply(text: cues[indexPath.row].lines.joined(separator: " "),
                   time: focused ? Self.clock(cues[indexPath.row].start) : nil,
                   query: query,
                   emphasize: active,
                   dimmed: !query.isEmpty && !hasMatch && indexPath.row != playingIndex,
                   playing: indexPath.row == playingIndex,
                   highlighted: indexPath.row == playingIndex || focused || active)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        focus(indexPath.row)
    }

    private static func clock(_ seconds: TimeInterval) -> String {
        let total = max(0, Int(seconds))
        let minutes = total / 60
        let secs = total % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}

private final class CaptionLineCell: UITableViewCell {
    static let reuseID = "CaptionLineCell"
    private let bar = UIView()
    private let body = UILabel()
    private let timeLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        bar.backgroundColor = .white
        bar.layer.cornerRadius = 1
        body.font = .systemFont(ofSize: 14)
        body.textColor = .white
        body.numberOfLines = 0
        timeLabel.font = .systemFont(ofSize: 14)
        timeLabel.textColor = UIColor.white.withAlphaComponent(0.64)
        timeLabel.numberOfLines = 1
        timeLabel.setContentHuggingPriority(.required, for: .horizontal)
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        body.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        body.setContentHuggingPriority(.defaultLow, for: .horizontal)
        let row = UIStackView(arrangedSubviews: [bar, body, timeLabel])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 8
        row.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(row)
        NSLayoutConstraint.activate([
            bar.widthAnchor.constraint(equalToConstant: 3),
            bar.heightAnchor.constraint(equalToConstant: 16),
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(text: String, time: String?, query: String, emphasize: Bool, dimmed: Bool, playing: Bool, highlighted: Bool) {
        bar.isHidden = !playing
        timeLabel.text = time
        timeLabel.isHidden = time == nil
        body.alpha = dimmed ? 0.45 : 1
        contentView.backgroundColor = highlighted ? UIColor(white: 17.0 / 255.0, alpha: 1) : .clear
        guard !query.isEmpty else {
            body.attributedText = nil
            body.text = text
            return
        }
        let attributed = NSMutableAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.white
        ])
        var search = text.startIndex
        while let range = text.range(of: query, options: .caseInsensitive, range: search..<text.endIndex) {
            let color = emphasize
                ? CaptionsSearchView.highlightColor
                : CaptionsSearchView.highlightColor.withAlphaComponent(0.45)
            attributed.addAttribute(.backgroundColor, value: color, range: NSRange(range, in: text))
            search = range.upperBound
        }
        body.attributedText = attributed
    }
}

extension CaptionsSearchView {
    static var highlightColor: UIColor { highlight }
}
