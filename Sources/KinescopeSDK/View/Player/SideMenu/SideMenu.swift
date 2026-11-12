//
//  SideMenu.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 02.04.2021.
//
// swiftlint:disable implicitly_unwrapped_optional

import UIKit
import Foundation

protocol SideMenuDelegate: AnyObject {
    func sideMenuWillBeDismissed(_ sideMenu: SideMenu, withRoot: Bool)
    func sideMenuDidSelect(item: SideMenu.Item, rowIndex: Int, sideMenu: SideMenu)
    func downloadAllTapped(for title: String)
}

final class SideMenu: UIView {

    // MARK: - Nested Types

    enum Settings {
        case playbackSpeed
        case subtitles
        case quality
        case audio
        case chapters
        case playlist
        case subtitleLook
        case fontColor
        case fontSize
        case backgroundColor
        case backgroundOpacity
        case subtitleSearch
        case videoScale
        case none

        static func getType(by title: String) -> Settings {
            switch title {
            case L10n.Player.playbackSpeed:
                return .playbackSpeed
            case L10n.Player.subtitles:
                return .subtitles
            case L10n.Player.videoQuality:
                return .quality
            case L10n.Player.audio:
                return .audio
            case L10n.Player.chapters:
                return .chapters
            case L10n.Player.playlist:
                return .playlist
            case L10n.Player.subtitleLook:
                return .subtitleLook
            case L10n.Player.fontColor:
                return .fontColor
            case L10n.Player.fontSize:
                return .fontSize
            case L10n.Player.backgroundColor:
                return .backgroundColor
            case L10n.Player.backgroundOpacity:
                return .backgroundOpacity
            case L10n.Player.subtitleSearch:
                return .subtitleSearch
            case L10n.Player.scale:
                return .videoScale
            default:
                return .none
            }
        }
    }

    enum DescriptionTitle {
        case attachments
        case download
        case subtitleSearch
        case chapters
        case none

        static func getType(by title: String) -> DescriptionTitle {
            switch title {
            case L10n.Player.attachments:
                return .attachments
            case L10n.Player.download:
                return .download
            case L10n.Player.subtitleSearch:
                return .subtitleSearch
            case L10n.Player.chapters:
                return .chapters
            default:
                return .none
            }
        }
    }

    enum Item {
        case disclosure(title: String, value: NSAttributedString?, icon: UIImage? = nil)
        case checkmark(title: NSAttributedString, selected: Bool = false)
        case description(id: String, title: String, value: String)
    }

    struct Model {
        let title: String
        let isRoot: Bool
        let isDownloadable: Bool
        var items: [Item]
        var showsSearch = false
        var showsCloseButton = true
    }

    private enum Constants {
        static let rowHeight: CGFloat = 48
        static let bottomPadding: CGFloat = 8
        static let cornerRadius: CGFloat = 6
        static let searchHeight: CGFloat = 36
    }

    // MARK: - Views

    private weak var tableView: UITableView!
    private weak var bar: SideMenuBar!

    // MARK: - Properties

    var title: String {
        model.title
    }
    var preferredHeight: CGFloat {
        let search = model.showsSearch ? Constants.searchHeight : 0
        return config.bar.preferedHeight + search + CGFloat(model.items.count) * Constants.rowHeight + Constants.bottomPadding
    }
    weak var delegate: SideMenuDelegate?

    // MARK: - Private Properties

    private let config: KinescopeSideMenuConfiguration
    private var model: Model
    private var query = ""
    private let searchField = UITextField()

    private var visibleItems: [Item] {
        guard model.showsSearch, !query.isEmpty else {
            return model.items
        }
        let needle = query.lowercased()
        return model.items.filter { item in
            guard case .description(_, let title, _) = item else {
                return true
            }
            return title.lowercased().contains(needle)
        }
    }

    // MARK: - Init

    init(config: KinescopeSideMenuConfiguration, model: Model) {
        self.config = config
        self.model = model
        super.init(frame: .zero)
        setupInitialState()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - UITableViewDataSource

extension SideMenu: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = visibleItems[indexPath.row]

        switch item {
        case .disclosure(let title, let value, let icon):
            let cell = tableView.dequeueReusableCell(withIdentifier: DisclosureCell.description(),
                                                     for: indexPath)
            (cell as? DisclosureCell)?.configure(with: .init(title: title,
                                                             value: value,
                                                             icon: icon,
                                                             config: config.item))
            return cell
        case .checkmark(let title, let selected):
            let cell = tableView.dequeueReusableCell(withIdentifier: CheckmarkCell.description(),
                                                     for: indexPath)
            (cell as? CheckmarkCell)?.configure(with: .init(title: title,
                                                            selected: selected,
                                                            config: config.item))
            return cell
        case .description(_, let title, let value):
            let cell = tableView.dequeueReusableCell(withIdentifier: DescriptionCell.description(),
                                                     for: indexPath)
            (cell as? DescriptionCell)?.configure(with: .init(title: title,
                                                              value: value,
                                                              config: config.item))
            return cell
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        visibleItems.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.rowHeight
    }

}

// MARK: - UITableViewDelegate

extension SideMenu: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let item = visibleItems[indexPath.row]

        delegate?.sideMenuDidSelect(item: item, rowIndex: indexPath.row, sideMenu: self)

        tableView.deselectRow(at: indexPath, animated: true)

    }

    func setDisclosureValue(_ value: NSAttributedString?, for title: String) {
        for index in model.items.indices {
            guard case .disclosure(let itemTitle, _, let icon) = model.items[index], itemTitle == title else {
                continue
            }
            model.items[index] = .disclosure(title: itemTitle, value: value, icon: icon)
        }
        tableView.reloadData()
    }

    func setDisplayedTitle(_ title: String) {
        bar.setDisplayedTitle(title)
    }

}

// MARK: - SideMenuBarDelegate

extension SideMenu: SideMenuBarDelegate {

    func closeTapped() {
        delegate?.sideMenuWillBeDismissed(self, withRoot: true)
    }

    func backTapped() {
        delegate?.sideMenuWillBeDismissed(self, withRoot: false)
    }

    func downloadAllTapped(for title: String) {
        delegate?.downloadAllTapped(for: title)
        delegate?.sideMenuWillBeDismissed(self, withRoot: true)
    }

}

// MARK: - Private

private extension SideMenu {

    func setupInitialState() {
        backgroundColor = config.backgroundColor
        layer.cornerRadius = Constants.cornerRadius
        clipsToBounds = true

        configureBar()
        configureSearchField()
        configureTableView()
    }

    func configureSearchField() {
        guard model.showsSearch else {
            return
        }
        searchField.placeholder = L10n.Player.subtitleSearch
        searchField.textColor = .white
        searchField.tintColor = .white
        searchField.font = KinescopeFont.regular(14)
        searchField.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        searchField.layer.cornerRadius = 6
        searchField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 1))
        searchField.leftViewMode = .always
        searchField.autocorrectionType = .no
        searchField.returnKeyType = .search
        searchField.addTarget(self, action: #selector(searchChanged), for: .editingChanged)
        addSubview(searchField)
        searchField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: bar.bottomAnchor, constant: 4),
            searchField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            searchField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            searchField.heightAnchor.constraint(equalToConstant: Constants.searchHeight - 8)
        ])
    }

    @objc
    func searchChanged() {
        query = searchField.text ?? ""
        tableView.reloadData()
    }

    func configureTableView() {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInset.bottom = Constants.bottomPadding
        tableView.alwaysBounceVertical = false
        tableView.showsVerticalScrollIndicator = true
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.insetsContentViewsToSafeArea = false

        addSubview(tableView)
        bottomChild(view: tableView)

        let topAnchor = model.showsSearch ? searchField.bottomAnchor : bar.bottomAnchor
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor)
        ])

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(DisclosureCell.self, forCellReuseIdentifier: DisclosureCell.description())
        tableView.register(CheckmarkCell.self, forCellReuseIdentifier: CheckmarkCell.description())
        tableView.register(DescriptionCell.self, forCellReuseIdentifier: DescriptionCell.description())

        self.tableView = tableView
    }

    func configureBar() {
        let bar = SideMenuBar(config: config.bar,
                              model: .init(title: model.title,
                                           isRoot: model.isRoot,
                                           isDownloadable: model.isDownloadable,
                                           showsCloseButton: model.showsCloseButton))

        addSubview(bar)
        topChild(view: bar, padding: 0)

        bar.delegate = self

        self.bar = bar
    }

}
