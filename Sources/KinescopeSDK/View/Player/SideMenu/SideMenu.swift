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
        case none

        static func getType(by title: String) -> Settings {
            switch title {
            case L10n.Player.playbackSpeed:
                return .playbackSpeed
            case L10n.Player.subtitles:
                return .subtitles
            case L10n.Player.videoQuality:
                return .quality
            default:
                return .none
            }
        }
    }

    enum DescriptionTitle {
        case attachments
        case download
        case none

        static func getType(by title: String) -> DescriptionTitle {
            switch title {
            case L10n.Player.attachments:
                return .attachments
            case L10n.Player.download:
                return .download
            default:
                return .none
            }
        }
    }

    enum Item {
        case disclosure(title: String, value: NSAttributedString?)
        case checkmark(title: NSAttributedString, selected: Bool = false)
        case description(title: String, value: String)
    }

    struct Model {
        let title: String
        let isRoot: Bool
        let isDownloadable: Bool
        let items: [Item]
    }

    // MARK: - Views

    private weak var tableView: UITableView!
    private weak var bar: SideMenuBar!

    // MARK: - Properties

    var title: String {
        model.title
    }
    weak var delegate: SideMenuDelegate?

    // MARK: - Private Properties

    private let config: KinescopeSideMenuConfiguration
    private let model: Model

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
        let item = model.items[indexPath.row]

        switch item {
        case .disclosure(let title, let value):
            let cell = tableView.dequeueReusableCell(withIdentifier: DisclosureCell.description(),
                                                     for: indexPath)
            (cell as? DisclosureCell)?.configure(with: .init(title: title,
                                                             value: value,
                                                             config: config.item))
            return cell
        case .checkmark(let title, let selected):
            let cell = tableView.dequeueReusableCell(withIdentifier: CheckmarkCell.description(),
                                                     for: indexPath)
            (cell as? CheckmarkCell)?.configure(with: .init(title: title,
                                                            selected: selected,
                                                            config: config.item))
            return cell
        case .description(let title, let value):
            let cell = tableView.dequeueReusableCell(withIdentifier: DescriptionCell.description(),
                                                     for: indexPath)
            (cell as? DescriptionCell)?.configure(with: .init(title: title,
                                                              value: value,
                                                              config: config.item))
            return cell
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.items.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        36
    }

}

// MARK: - UITableViewDelegate

extension SideMenu: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let item = model.items[indexPath.row]

        delegate?.sideMenuDidSelect(item: item, rowIndex: indexPath.row, sideMenu: self)

        tableView.deselectRow(at: indexPath, animated: true)

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

        configureBar()
        configureTableView()
    }

    func configureTableView() {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none

        addSubview(tableView)
        bottomChild(view: tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: bar.bottomAnchor)
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
                              model: .init(title: model.title, isRoot: model.isRoot, isDownloadable: model.isDownloadable))

        addSubview(bar)
        topChild(view: bar, padding: 0)

        bar.delegate = self

        self.bar = bar
    }

}
