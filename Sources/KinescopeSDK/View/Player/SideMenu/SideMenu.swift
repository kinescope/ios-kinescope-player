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
}

final class SideMenu: UIView {

    struct Model {
        let title: String
        let isRoot: Bool
        let items: [Any]
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

// MARK: - SideMenuBarDelegate

extension SideMenu: SideMenuBarDelegate {

    func closeTapped() {
        delegate?.sideMenuWillBeDismissed(self, withRoot: true)
    }

    func backTapped() {
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
