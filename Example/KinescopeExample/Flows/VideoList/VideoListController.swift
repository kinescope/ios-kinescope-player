//
//  VideoListController.swift
//  KinescopeExample
//
//  Created by Никита Коробейников on 23.03.2021.
//

import UIKit
import ReactiveDataDisplayManager
import KinescopeSDK

/// Example of video gallery
final class VideoListController: UIViewController {

    // MARK: - Constants

    private enum Constants {
        static let pageSize = 16
        static let pagesCount = 3
    }

    // MARK: - IBOutlet

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Private Properties

    private lazy var progressView = PaginatorView(frame: .init(x: 0,
                                                               y: 0,
                                                               width: tableView.frame.width,
                                                               height: 80))

    private lazy var adapter = tableView.rddm.baseBuilder
        .add(plugin: .paginatable(progressView: progressView,
                                  output: self))
        .add(plugin: .currentFocus())
        .build()

    private weak var paginatableInput: PaginatableInput?

    private var currentPage = 0

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Video List"
        loadFirstPage()
    }

}

// MARK: - Private Methods

private extension VideoListController {

    func loadFirstPage() {

        // show loader
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()

        // hide footer
        paginatableInput?.updatePagination(canIterate: false)

        // imitation of loading first page
        delay(.now() + .seconds(3)) { [weak self] in

            // fill table
            self?.fillAdapter()

            // hide loader
            self?.activityIndicator?.stopAnimating()
            self?.activityIndicator?.isHidden = true

            // show footer
            self?.paginatableInput?.updatePagination(canIterate: true)
        }
    }

    /// This method is used to fill adapter
    func fillAdapter() {

        for i in 0...Constants.pageSize {
            adapter.addCellGenerator(makeGenerator(with: "\(currentPage)_\(i)"))
        }

        adapter.forceRefill()
    }

    func delay(_ deadline: DispatchTime, completion: @escaping () -> Void) {
        DispatchQueue.global().asyncAfter(deadline: deadline) {
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    func makeGenerator(with title: String) -> BaseCellGenerator<VideoListCell> {
        VideoListFocusableCellGenerator(with: .init(title: title))
    }

    func fillNext() -> Bool {
        currentPage += 1

        for i in 0...Constants.pageSize {
            adapter.addCellGenerator(makeGenerator(with: "\(currentPage)_\(i)"))
        }

        adapter.forceRefill()

        return currentPage < Constants.pagesCount
    }

}


// MARK: - RefreshableOutput

extension VideoListController: PaginatableOutput {

    func onPaginationInitialized(with input: PaginatableInput) {
        paginatableInput = input
    }

    func loadNextPage(with input: PaginatableInput) {

        input.updateProgress(isLoading: true)

        delay(.now() + .seconds(3)) { [weak self, weak input] in
            let canIterate = self?.fillNext() ?? false

            input?.updateProgress(isLoading: false)
            input?.updatePagination(canIterate: canIterate)
        }
    }

}
