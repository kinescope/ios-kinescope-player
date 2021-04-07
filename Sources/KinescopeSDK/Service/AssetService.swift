//
//  AssetService.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 07.04.2021.
//

import AVFoundation

protocol AssetServiceDelegate {
    func downloadProgress(assetId: String, progress: Double)
    func downloadError(assetId: String, error: KinescopeDownloadError)
    func downloadComplete(assetId: String, path: String)
}

protocol AssetService {

    var delegate: AssetServiceDelegate? { get set }

    func enqeueDownload(assetId: String)

    func pauseDownload(assetId: String)

    func resumeDownload(assetId: String)

    func deqeueDownload(assetId: String)

    func restore()

}

class AssetNetworkService: NSObject, AssetService {

    // MARK: - Constants

    private enum Constants {
        static let downloadIdentifier = "kinescope_download_session"
    }

    // MARK: - Properties

    var delegate: AssetServiceDelegate?
    private let idsStorage = IDsUDStorage()
    private lazy var session: AVAssetDownloadURLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: Constants.downloadIdentifier)

        // Create a new AVAssetDownloadURLSession
        let downloadSession = AVAssetDownloadURLSession(configuration: configuration,
                                                        assetDownloadDelegate: self,
                                                        delegateQueue: OperationQueue.main)

        return downloadSession
    }()

}

// MARK: - AssetService

extension AssetNetworkService {

    func enqeueDownload(assetId: String) {
    }

    func pauseDownload(assetId: String) {
        findTask(by: assetId) { task, _ in
            task.suspend()
        }
    }

    func resumeDownload(assetId: String) {
        findTask(by: assetId) { task, _ in
            task.resume()
        }
    }

    func deqeueDownload(assetId: String) {
        findTask(by: assetId) { [weak self] task, url in
            task.cancel()
            self?.idsStorage.deleteID(by: url)
        }
    }

    func restore() {
        session.getAllTasks { tasksArray in
            // For each task, restore the state in the app
            for task in tasksArray {
                guard let downloadTask = task as? AVAssetDownloadTask else { break }
                // Restore asset, progress indicators, state, etc...
                let asset = downloadTask.urlAsset
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
        guard let id = getId(for: assetDownloadTask) else { return }
        delegate?.downloadComplete(assetId: id, path: location.relativePath)
    }

    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue], timeRangeExpectedToLoad: CMTimeRange) {
        guard let id = getId(for: assetDownloadTask) else { return }
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

    func findTask(by assetId: String, completion: @escaping (URLSessionTask, String) -> ()) {
        session.getAllTasks { [weak self] tasksArray in
            for task in tasksArray {
                guard let downloadTask = task as? AVAssetDownloadTask else { break }
                if
                    let id = self?.idsStorage.readID(by: downloadTask.urlAsset.url.absoluteString),
                    id == assetId
                {
                    completion(task, downloadTask.urlAsset.url.absoluteString)
                }
            }
        }

    }

    func startTask(url urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let asset = AVURLAsset(url: url)

        // Create new AVAssetDownloadTask for the desired asset
        let downloadTask = session.makeAssetDownloadTask(asset: asset,
                                                         assetTitle: "kinescope_\(urlString)",
                                                         assetArtworkData: nil,
                                                         options: nil)
        // Start task and begin download
        downloadTask?.resume()
    }

}
