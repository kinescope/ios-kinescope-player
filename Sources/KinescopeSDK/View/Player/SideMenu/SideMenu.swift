//
//  SideMenu.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 02.04.2021.
//
// swiftlint:disable implicitly_unwrapped_optional

import UIKit

protocol SideMenuDelegate: class {
    func sideMenuWillBeDismissed(_ sideMenu: SideMenu, withRoot: Bool)
    func sideMenuDidSelect(item: SideMenu.Item, sideMenu: SideMenu)
}

final class SideMenu: UIView {

    // FIXME: Add localization
    enum Settings: String {
        case playbackSpeed = "Playback speed"
        case subtitles = "Subtitles"
        case quality = "Quality"

        static var title = "Settings"
    }

    enum Item {
        case disclosure(title: String, value: NSAttributedString?)
        case checkmark(title: NSAttributedString, selected: Bool = false)
    }

    struct Model {
        let title: String
        let isRoot: Bool
        let items: [Item]
    }

    // MARK: - Views

    private weak var tableView: UITableView!
    private weak var bar: SideMenuBar!

    // MARK: - Properties

    private let config: KinescopeSideMenuConfiguration
    private let model: Model

    weak var delegate: SideMenuDelegate?

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

        delegate?.sideMenuDidSelect(item: item, sideMenu: self)

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

        self.tableView = tableView
    }

    func configureBar() {
        let bar = SideMenuBar(config: config.bar,
                              model: .init(title: model.title, isRoot: model.isRoot))

        addSubview(bar)
        topChild(view: bar, padding: 0)

        bar.delegate = self

        self.bar = bar
    }

}
