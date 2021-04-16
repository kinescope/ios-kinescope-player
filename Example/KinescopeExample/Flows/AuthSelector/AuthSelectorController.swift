//
//  AuthSelectorController.swift
//  KinescopeExample
//
//  Created by Никита Коробейников on 25.03.2021.
//

import UIKit
import ReactiveDataDisplayManager
import KinescopeSDK

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
        navigationItem.title = "Who are you?"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: nil,
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)
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

        let generators = users.map(makeGenerator(from:))

        adapter.addCellGenerators(generators)

        adapter.forceRefill()
    }

    func makeGenerator(from user: User) -> BaseCellGenerator<UserCell> {
        let generator = UserCell.rddm.baseGenerator(with: user)

        generator.didSelectEvent += { [weak self] in
            self?.onSelect(user: user)
        }

        return generator
    }

    func onSelect(user: User) {

        /// Set apiKey
        Kinescope.shared.setConfig(.init(apiKey: user.apiKey))

        /// Set logger
        Kinescope.shared.set(logger: KinescopeDefaultLogger(),
                             levels: KinescopeLoggerLevel.allCases)

        /// Push to next
        performSegue(withIdentifier: "toVideos", sender: nil)

    }

}
