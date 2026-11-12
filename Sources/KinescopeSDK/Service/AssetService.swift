import AVFoundation

protocol AssetServiceDelegate: AnyObject {
    func downloadProgress(assetId: String, progress: Double)
    func downloadError(assetId: String, error: KinescopeDownloadError)
    func downloadComplete(assetId: String, path: String)
}

protocol AssetService {
    var delegate: AssetServiceDelegate? { get set }
    func enqueueDownload(assetId: String, url: URL, video: KinescopeVideo?, minimumHeight: Int?)
    func pauseDownload(assetId: String)
    func resumeDownload(assetId: String)
    func dequeueDownload(assetId: String)
    func restore()
}

class AssetNetworkService: NSObject, AssetService {

    private enum Constants {
        static let downloadIdentifier = "io.kinescope.asset_download_session"
    }

    weak var delegate: AssetServiceDelegate?
    private let idsStorage: IDsStorage
    private let drmFactory: DataProtectionHandlerFactory?
    private var drmHandlers: [String: DataProtectionHandler] = [:]
    /// Bumped every time a video is downloaded again. A finished id must not swallow the next attempt.
    private var downloadAttempt: [String: Int] = [:]
    private var publishedAttempts = Set<String>()
    private lazy var session: AVAssetDownloadURLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: Constants.downloadIdentifier)
        let downloadSession = AVAssetDownloadURLSession(configuration: configuration,
                                                        assetDownloadDelegate: self,
                                                        delegateQueue: nil)

        return downloadSession
    }()

    init(idsStorage: IDsStorage = IDsUDStorage(), drmFactory: DataProtectionHandlerFactory? = nil) {
        self.idsStorage = idsStorage
        self.drmFactory = drmFactory
    }

    func setSession(_ session: AVAssetDownloadURLSession) {
        self.session = session
    }

}

extension AssetNetworkService {

    func enqueueDownload(assetId: String, url: URL, video: KinescopeVideo?, minimumHeight: Int?) {
        findTask(by: assetId) { task in
            task.resume()
        } notFoundCompletion: { [weak self] in
            guard let self else { return }
            self.downloadAttempt[assetId, default: 0] += 1
            self.idsStorage.save(id: assetId, by: url.absoluteString)
            self.startTask(assetId: assetId, url: url, video: video, minimumHeight: minimumHeight)
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
            self?.idsStorage.deleteID(by: task.urlAsset.url.absoluteString)
            self?.drmHandlers.removeValue(forKey: assetId)
            task.cancel()
        } notFoundCompletion: { [weak self] in
            self?.delegate?.downloadError(assetId: assetId, error: .notFound)
        }
    }

    func restore() {
        let pending = idsStorage.fetchAll()
        guard !pending.isEmpty else {
            return
        }
        // The content-key session has to exist before this process reconnects the background
        // download session. Binding the task asset happens once that session lists its tasks.
        for (_, assetId) in pending {
            warmKeySession(assetId: assetId)
        }
        session.getAllTasks { [weak self] tasksArray in
            guard let self else { return }
            for task in tasksArray {
                guard let downloadTask = task as? AVAssetDownloadTask else { continue }
                let url = downloadTask.urlAsset.url.absoluteString
                guard let assetId = self.idsStorage.readID(by: url) else { continue }
                self.bindKeySession(assetId: assetId, asset: downloadTask.urlAsset)
                downloadTask.resume()
            }
        }
    }

}

extension AssetNetworkService: AVAssetDownloadDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let task = task as? AVAssetDownloadTask,
              let id = idsStorage.readID(by: task.urlAsset.url.absoluteString) else {
            return
        }
        let path = PendingAssetLocations.path(for: id)
        let manifestURL = task.urlAsset.url.absoluteString
        let attempt = downloadAttempt[id] ?? 0

        if let error {
            publishDownload(id: id, attempt: attempt, manifestURL: manifestURL, result: .failure(.unknown(error)))
            return
        }

        guard let path, FileManager.default.fileExists(atPath: path) else {
            publishDownload(id: id, attempt: attempt, manifestURL: manifestURL, result: .failure(.unknown(IncompleteDownload())))
            return
        }

        let needsKey = OfflineVideoStore.video(for: id)?.drm != nil
        if !needsKey || PersistentContentKeyStore.exists(for: id) {
            publishDownload(id: id, attempt: attempt, manifestURL: manifestURL, result: .success(path))
            return
        }

        // The license request is still on the network. Failing here deleted a finished package.
        if let handler = drmHandlers[id] as? DataProtectionKeySessionHandler {
            handler.whenPersistentKeyResolved { [weak self] keyResult in
                guard let self else { return }
                switch keyResult {
                case .success:
                    if PersistentContentKeyStore.exists(for: id) {
                        self.publishDownload(id: id, attempt: attempt, manifestURL: manifestURL, result: .success(path))
                    } else {
                        try? FileManager.default.removeItem(atPath: path)
                        self.publishDownload(id: id, attempt: attempt, manifestURL: manifestURL, result: .failure(.unknown(IncompleteDownload())))
                    }
                case .failure(let keyError):
                    try? FileManager.default.removeItem(atPath: path)
                    self.publishDownload(id: id, attempt: attempt, manifestURL: manifestURL, result: .failure(.unknown(keyError)))
                }
            }
            return
        }

        try? FileManager.default.removeItem(atPath: path)
        publishDownload(id: id, attempt: attempt, manifestURL: manifestURL, result: .failure(.unknown(IncompleteDownload())))
    }

    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        guard let id = getId(for: assetDownloadTask) else {
            return
        }
        // The package is on disk, but the session can still fail and a DRM key may still be missing.
        // `didCompleteWithError` is what publishes the download.
        PendingAssetLocations.save(location.path, for: id)
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
        for value in loadedTimeRanges {
            let loadedTimeRange = value.timeRangeValue
            percentComplete += loadedTimeRange.duration.seconds / timeRangeExpectedToLoad.duration.seconds
        }
        percentComplete *= 100
        delegate?.downloadProgress(assetId: id, progress: percentComplete)
    }

}

private extension AssetNetworkService {

    func publishDownload(id: String, attempt: Int, manifestURL: String, result: Result<String, KinescopeDownloadError>) {
        guard (downloadAttempt[id] ?? 0) == attempt else {
            return
        }
        guard publishedAttempts.insert("\(id)#\(attempt)").inserted else {
            return
        }
        PendingAssetLocations.remove(id)
        idsStorage.deleteID(by: manifestURL)
        drmHandlers.removeValue(forKey: id)
        switch result {
        case .success(let path):
            delegate?.downloadComplete(assetId: id, path: path)
        case .failure(let error):
            delegate?.downloadError(assetId: id, error: error)
        }
    }

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

    func warmKeySession(assetId: String) {
        guard drmHandlers[assetId] == nil,
              let video = OfflineVideoStore.video(for: assetId),
              let handler = DataProtectionHandlers.make(for: video, persistable: true) else {
            return
        }
        (handler as? DataProtectionKeySessionHandler)?.prepareSession()
        drmHandlers[assetId] = handler
    }

    func bindKeySession(assetId: String, asset: AVURLAsset) {
        warmKeySession(assetId: assetId)
        drmHandlers[assetId]?.bind(with: asset)
    }

    func startTask(assetId: String, url: URL, video: KinescopeVideo?, minimumHeight: Int?) {
        let asset = AVURLAsset(url: url)
        if let video = video, video.drm != nil,
           let drmHandler = DataProtectionHandlers.make(for: video, persistable: true) ?? drmFactory?.provide(for: video) {
            drmHandler.bind(with: asset)
            drmHandlers[assetId] = drmHandler
        }
        var options: [String: Any]?
        if let minimumHeight, minimumHeight > 0 {
            let width = Int((Double(minimumHeight) * 16.0 / 9.0).rounded())
            let size = CGSize(width: width, height: minimumHeight)
            options = [AVAssetDownloadTaskMinimumRequiredPresentationSizeKey: NSValue(cgSize: size)]
        }
        let downloadTask = session.makeAssetDownloadTask(asset: asset,
                                                         assetTitle: "io.kinescope.\(assetId)",
                                                         assetArtworkData: nil,
                                                         options: options)
        downloadTask?.resume()
    }

}

/// Location from `didFinishDownloadingTo`, kept until `didCompleteWithError` decides the outcome.
/// A relaunch can deliver the completion callback without the in-memory task.
private enum PendingAssetLocations {

    private static let key = "io.kinescope.asset_download_locations"

    static func save(_ path: String, for assetId: String) {
        var dict = UserDefaults.standard.dictionary(forKey: key) as? [String: String] ?? [:]
        dict[assetId] = path
        UserDefaults.standard.set(dict, forKey: key)
    }

    static func path(for assetId: String) -> String? {
        let dict = UserDefaults.standard.dictionary(forKey: key) as? [String: String]
        return dict?[assetId]
    }

    static func remove(_ assetId: String) {
        var dict = UserDefaults.standard.dictionary(forKey: key) as? [String: String] ?? [:]
        dict.removeValue(forKey: assetId)
        UserDefaults.standard.set(dict, forKey: key)
    }

}

private struct IncompleteDownload: LocalizedError {
    var errorDescription: String? {
        "The download finished without a local file or a FairPlay key."
    }
}
