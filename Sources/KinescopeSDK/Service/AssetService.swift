//
//  AssetService.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 07.04.2021.
//

import AVFoundation

protocol AssetServiceDelegate: class {
    func downloadProgress(assetId: String, progress: Double)
    func downloadError(assetId: String, error: KinescopeDownloadError)
    func downloadComplete(assetId: String, path: String)
}

protocol AssetService {
    var delegate: AssetServiceDelegate? { get set }
    func enqueueDownload(assetId: String)
    func pauseDownload(assetId: String)
    func resumeDownload(assetId: String)
    func dequeueDownload(assetId: String)
    func restore()
}

class AssetNetworkService: NSObject, AssetService {

    // MARK: - Constants

    private enum Constants {
        static let downloadIdentifier = "io.kinescope.download_session"
    }

    // MARK: - Properties

    weak var delegate: AssetServiceDelegate?
    private let idsStorage: IDsStorage
    private let assetLinksService: AssetLinksService
    private lazy var session: AVAssetDownloadURLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: Constants.downloadIdentifier)

        // Create a new AVAssetDownloadURLSession
        let downloadSession = AVAssetDownloadURLSession(configuration: configuration,
                                                        assetDownloadDelegate: self,
                                                        delegateQueue: nil)

        return downloadSession
    }()

    // MARK: - Lyfecycle

    init(assetLinksService: AssetLinksService,
         idsStorage: IDsStorage = IDsUDStorage()) {
        self.assetLinksService = assetLinksService
        self.idsStorage = idsStorage
    }

}

// MARK: - AssetService

extension AssetNetworkService {

    func enqueueDownload(assetId: String) {
        findTask(by: assetId) { task in
            task.resume()
        } notFoundCompletion: { [weak self] in
            self?.assetLinksService.getAssetLink(by: assetId) { [weak self] in
                switch $0 {
                case .success(let link):
                    self?.idsStorage.save(id: assetId, by: link.link)
                    self?.startTask(url: link.link)
                case .failure(_):
                    self?.delegate?.downloadError(assetId: assetId, error: .notFound)
                }
            }
        }
    }

    func pauseDownload(assetId: String) {
        findTask(by: assetId) { task in
            task.suspend()
        } notFoundCompletion: { [weak self] in
            self?.delegate?.downloadError(assetId: assetId, error: .notFound)
        }
    }

    func resumeDownload(assetId: String) {
        findTask(by: assetId) { task in
            task.resume()
        } notFoundCompletion: { [weak self] in
            self?.delegate?.downloadError(assetId: assetId, error: .notFound)
        }
    }

    func dequeueDownload(assetId: String) {
        findTask(by: assetId) { [weak self] task in
            task.cancel()
            self?.idsStorage.deleteID(by: task.urlAsset.url.absoluteString)
        } notFoundCompletion: { [weak self] in
            self?.delegate?.downloadError(assetId: assetId, error: .notFound)
        }
    }

    func restore() {
        session.getAllTasks { [weak self] tasksArray in
            // For each task, restore the state in the app
            for task in tasksArray {
                guard let downloadTask = task as? AVAssetDownloadTask else { break }
                if self?.idsStorage.contains(url: downloadTask.urlAsset.url.absoluteString) ?? false {
                    downloadTask.resume()
                }
            }
        }
    }

}

// MARK: - AVAssetDownloadDelegate

extension AssetNetworkService: AVAssetDownloadDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard
            let error = error,
            let task = task as? AVAssetDownloadTask,
            let id = idsStorage.deleteID(by: task.urlAsset.url.absoluteString)
        else {
            return
        }
        delegate?.downloadError(assetId: id, error: .unknown(error))
    }

    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        guard let id = idsStorage.deleteID(by: assetDownloadTask.urlAsset.url.absoluteString) else {
            return
        }
        delegate?.downloadComplete(assetId: id, path: location.relativePath)
    }

    func urlSession(_ session: URLSession,
                    assetDownloadTask: AVAssetDownloadTask,
                    didLoad timeRange: CMTimeRange,
                    totalTimeRangesLoaded loadedTimeRanges: [NSValue],
                    timeRangeExpectedToLoad: CMTimeRange) {
        guard let id = getId(for: assetDownloadTask) else {
            return
        }
        var percentComplete = 0.0
        // Iterate through the loaded time ranges
        for value in loadedTimeRanges {
            // Unwrap the CMTimeRange from the NSValue
            let loadedTimeRange = value.timeRangeValue
            // Calculate the percentage of the total expected asset duration
            percentComplete += loadedTimeRange.duration.seconds / timeRangeExpectedToLoad.duration.seconds
        }
        percentComplete *= 100
        delegate?.downloadProgress(assetId: id, progress: percentComplete)
    }

}

// MARK: - Private

private extension AssetNetworkService {

    func getId(for task: AVAssetDownloadTask) -> String? {
        return idsStorage.readID(by: task.urlAsset.url.absoluteString)
    }

    func findTask(by assetId: String, completion: @escaping (AVAssetDownloadTask) -> Void, notFoundCompletion: @escaping () -> Void) {
        session.getAllTasks { [weak self] tasksArray in
            for task in tasksArray {
                guard let downloadTask = task as? AVAssetDownloadTask else {
                    continue
                }
                if
                    let id = self?.idsStorage.readID(by: downloadTask.urlAsset.url.absoluteString),
                    id == assetId
                {
                    completion(downloadTask)
                    return
                }
            }
            notFoundCompletion()
        }
    }

    func startTask(url urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        let asset = AVURLAsset(url: url)

        // Create new AVAssetDownloadTask for the desired asset
        let downloadTask = session.makeAssetDownloadTask(asset: asset,
                                                         assetTitle: "io.kinescope.\(urlString)",
                                                         assetArtworkData: nil,
                                                         options: nil)

        // Start task and begin download
        downloadTask?.resume()
    }

}
