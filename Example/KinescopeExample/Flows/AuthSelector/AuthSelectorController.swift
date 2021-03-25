//
//  AuthSelectorController.swift
//  KinescopeExample
//
//  Created by Никита Коробейников on 25.03.2021.
//

import UIKit
import ReactiveDataDisplayManager

final class AuthSelectorController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var emptyView: UIView!

    // MARK: - Private Properties

    private lazy var adapter = tableView.rddm.baseBuilder
        .add(plugin: .selectable())
        .build()

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Who are you?"
        loadUsers()
    }

}

// MARK: - Private Methods

private extension AuthSelectorController {

    func loadUsers() {

        let users = ConfigStorage.read()

        fillAdapter(with: users)

        emptyView.isHidden = !users.isEmpty

    }

    func fillAdapter(with users: [User]) {

        adapter.clearCellGenerators()

        let generators = users.map { UserCell.rddm.baseGenerator(with: $0) }

        adapter.addCellGenerators(generators)

        adapter.forceRefill()
    }

}
