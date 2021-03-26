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

    // MARK: - IBOutlet

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            // Needs to make last cell focusable
            tableView.contentInset.bottom = 200
        }
    }
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Private Properties

    private lazy var progressView = PaginatorView(frame: .init(x: 0, y: 0, width: tableView.frame.width, height: 80))
    
    private lazy var adapter = tableView.rddm.baseBuilder
        .add(plugin: .selectable())
        .add(plugin: .paginatable(progressView: progressView,
                                  output: self))
        .add(plugin: .currentFocus(output: self))
        .build()

    private weak var focusInput: CurrentCellFocusInput?
    private weak var paginatableInput: PaginatableInput?

    private lazy var inspector: KinescopeInspectable = Kinescope.shared.inspector
    private var request = KinescopeVideosRequest(page: 1, perPage: 2)
    private var totalCount = 0

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Your videos"
        loadFirstPage()
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

private extension VideoListController {

    func loadFirstPage() {

        // show loader
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true

        // hide footer
        paginatableInput?.updatePagination(canIterate: false)

        // imitation of loading first page
        loadVideos { [weak self] canIterate in
            self?.activityIndicator?.stopAnimating()

            self?.paginatableInput?.updatePagination(canIterate: canIterate)
        }

    }

    func loadVideos(onComplete: @escaping (Bool) -> Void) {
        inspector.list(request: request,
                       onSuccess: { [weak self] response in
                            guard let self = self else {
                                return
                            }

                            self.fillAdapter(with: response.0)
                            self.totalCount += response.0.count
                            onComplete(response.1.pagination.total > self.totalCount)
                       },
                       onError: { _ in
                            print("Error loading videos")
                       })
    }

    func fillAdapter(with videos: [KinescopeVideo]) {


        let generators = videos.map { video -> BaseCellGenerator<VideoListCell> in
            let generator = VideoListFocusableCellGenerator(with: video)

            generator.didSelectEvent.addListner { [weak self] in
                self?.performSegue(withIdentifier: "toVideo", sender: video.id)
            }

            return generator
        }

        adapter.addCellGenerators(generators)

        adapter.forceRefill { [weak self] in
            self?.focusInput?.updateFocus()
        }
    }

}

// MARK: - CurrentCellFocusOutput

extension VideoListController: CurrentCellFocusOutput {

    func onFocusInitialized(with input: CurrentCellFocusInput) {
        self.focusInput = input
    }

}

// MARK: - PaginatableOutput

extension VideoListController: PaginatableOutput {

    func onPaginationInitialized(with input: PaginatableInput) {
        paginatableInput = input
    }

    func loadNextPage(with input: PaginatableInput) {

        input.updateProgress(isLoading: true)

        request = request.next()

        loadVideos { [weak input] canIterate in

            input?.updateProgress(isLoading: false)
            input?.updatePagination(canIterate: canIterate)
        }
    }

}
