import Foundation

class VideoDownloader: KinescopeVideoDownloadable {

    private var delegates: [KinescopeVideoDownloadableDelegate] = []

    private let videoPathsStorage: KinescopeVideoPathsStorage
    private var assetService: AssetService

    init(videoPathsStorage: KinescopeVideoPathsStorage,
         assetService: AssetService) {
        self.videoPathsStorage = videoPathsStorage
        self.assetService = assetService
        self.assetService.delegate = self
        // Reconnect unfinished background downloads once the key sessions exist.
        self.assetService.restore()
    }

    func enqueueDownload(videoId: String, url: URL) {
        assetService.enqueueDownload(assetId: videoId, url: url, video: nil, minimumHeight: nil)
    }

    func enqueueDownload(videoId: String, url: URL, video: KinescopeVideo?, minimumHeight: Int?) {
        if let video {
            OfflineVideoStore.save(video)
            savePoster(of: video)
        }
        assetService.enqueueDownload(assetId: videoId, url: url, video: video, minimumHeight: minimumHeight)
    }

    /// The poster is a remote image. Keep a copy beside the metadata so the offline
    /// player and the lock screen can show it without the network.
    private func savePoster(of video: KinescopeVideo) {
        guard let raw = video.poster?.url, let url = URL(string: raw), !raw.isEmpty else {
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data, !data.isEmpty else {
                return
            }
            OfflineVideoStore.savePoster(data, for: video.id)
        }.resume()
    }

    func resumeDownload(videoId: String) {
        assetService.resumeDownload(assetId: videoId)
    }

    func pauseDownload(videoId: String) {
        assetService.pauseDownload(assetId: videoId)
    }

    func dequeueDownload(videoId: String) {
        assetService.dequeueDownload(assetId: videoId)
    }

    func downloadedList() -> [String] {
        return videoPathsStorage.fetchVideoIds()
    }

    func getLocation(by videoId: String) -> URL? {
        return videoPathsStorage.readVideoUrl(by: videoId)
    }

    func posterLocation(by videoId: String) -> URL? {
        guard let url = OfflineVideoStore.posterFileURL(for: videoId),
              FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        return url
    }

    @discardableResult
    func delete(videoId: String) -> Bool {
        // A bookmark resolves to wherever the package is now. A missing file is already gone,
        // so the record must still be removed; otherwise the row stays in the list forever.
        if let assetUrl = videoPathsStorage.readVideoUrl(by: videoId),
           FileManager.default.fileExists(atPath: assetUrl.path) {
            do {
                try FileManager.default.removeItem(at: assetUrl)
            } catch {
                Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.network)
                return false
            }
        }
        videoPathsStorage.deleteVideoUrl(by: videoId)
        PersistentContentKeyStore.delete(for: videoId)
        OfflineVideoStore.delete(for: videoId)
        return true
    }

    func clear() {
        for videoId in downloadedList() {
            delete(videoId: videoId)
        }
    }

    func add(delegate: KinescopeVideoDownloadableDelegate) {
        delegates.append(delegate)
    }

    func remove(delegate: KinescopeVideoDownloadableDelegate) {
        if let index = delegates.firstIndex(where: { delegate === $0 }) {
            delegates.remove(at: index)
        }
    }

    func restore() {
        assetService.restore()
    }

}

extension VideoDownloader: AssetServiceDelegate {

    func downloadProgress(assetId: String, progress: Double) {
        Kinescope.shared.logger?.log(message: "Video \(assetId) download progress: \(progress)", level: KinescopeLoggerLevel.network)
        delegates.forEach {
            $0.videoDownloadProgress(videoId: assetId, progress: progress)
        }
    }

    func downloadError(assetId: String, error: KinescopeDownloadError) {
        Kinescope.shared.logger?.log(message: "Video \(assetId) download failed with \(error)", level: KinescopeLoggerLevel.network)
        delegates.forEach {
            $0.videoDownloadError(videoId: assetId, error: error)
        }
    }

    func downloadComplete(assetId: String, path: String) {
        Kinescope.shared.logger?.log(message: "Video \(assetId) download completed", level: KinescopeLoggerLevel.network)
        if path.hasPrefix("/"),
           (try? videoPathsStorage.saveBookmark(for: URL(fileURLWithPath: path), id: assetId)) != nil {
            // Bookmark replaces the absolute path. Older records stay as plain paths.
        } else {
            videoPathsStorage.saveVideo(relativeUrl: path, id: assetId)
        }
        delegates.forEach {
            $0.videoDownloadComplete(videoId: assetId)
        }
    }

}

/// Video metadata saved next to a download, so a downloaded video can start without the network.
/// Lives in this file because the Xcode and CocoaPods projects list sources explicitly:
/// a new file is invisible until the project is regenerated.
enum OfflineVideoStore {

    private static let folderName = "KinescopeOfflineVideos"

    static func video(for videoId: String) -> KinescopeVideo? {
        guard let url = fileURL(for: videoId),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return try? JSONDecoder().decode(KinescopeVideo.self, from: data)
    }

    static func save(_ video: KinescopeVideo) {
        guard let url = fileURL(for: video.id) else {
            return
        }
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                                    withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(video)
            try data.write(to: url, options: .completeFileProtectionUntilFirstUserAuthentication)
        } catch {
            Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.network)
        }
    }

    static func delete(for videoId: String) {
        if let url = fileURL(for: videoId) {
            try? FileManager.default.removeItem(at: url)
        }
        if let poster = posterFileURL(for: videoId) {
            try? FileManager.default.removeItem(at: poster)
        }
    }

    /// Local copy of the poster image, or `nil` when the video was never downloaded.
    static func posterFileURL(for videoId: String) -> URL? {
        fileURL(for: videoId)?.deletingPathExtension().appendingPathExtension("poster")
    }

    static func savePoster(_ data: Data, for videoId: String) {
        guard let url = posterFileURL(for: videoId) else {
            return
        }
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                                    withIntermediateDirectories: true)
            try data.write(to: url, options: .completeFileProtectionUntilFirstUserAuthentication)
        } catch {
            Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.network)
        }
    }

    private static func fileURL(for videoId: String) -> URL? {
        let safe = videoId.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? videoId
        guard !safe.isEmpty,
              let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        return base.appendingPathComponent(folderName, isDirectory: true).appendingPathComponent(safe + ".json")
    }

}
