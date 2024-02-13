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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard
            let destination = segue.destination as? VideoViewController,
            let id = sender as? String
        else {
            return
        }

        destination.videoId = id
    }
}

// MARK: - Private Methods

private extension AuthSelectorController {

    func loadUsers() {
        ConfigStorage.read { [weak self] users in
            self?.emptyView.isHidden = !users.isEmpty
            if users.isEmpty {
                self?.proceedAsGuest()

            } else {
                self?.fillAdapter(with: users)
            }
        }
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

    func proceedAsGuest() {
        /// Keep apiKey nil to show only public demo videos
        Kinescope.shared.setConfig(.init(apiKey: nil))

        /// Set logger
        Kinescope.shared.set(logger: KinescopeDefaultLogger(),
                             levels: KinescopeLoggerLevel.allCases)

        /// Play public demo video
        performSegue(withIdentifier: "toVideo", sender: "9L8KmbNuhQSxQofn5DR4Vg")
        // Play video with drm (device only)
//        performSegue(withIdentifier: "toVideo", sender: "200660125")
    }
}
