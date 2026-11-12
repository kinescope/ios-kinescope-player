import Foundation

public protocol KinescopeVideoDownloadable: AnyObject {

    func enqueueDownload(videoId: String, url: URL)
    /// Downloads one rendition when `minimumHeight` is set. Pass the video so a DRM download can keep an offline key.
    func enqueueDownload(videoId: String, url: URL, video: KinescopeVideo?, minimumHeight: Int?)
    func pauseDownload(videoId: String)
    func resumeDownload(videoId: String)
    func dequeueDownload(videoId: String)
    func isDownloaded(videoId: String) -> Bool
    func downloadedList() -> [String]
    func getLocation(by videoId: String) -> URL?
    /// Local poster saved with the download, or `nil` when that file is not on disk.
    func posterLocation(by videoId: String) -> URL?
    @discardableResult
    func delete(videoId: String) -> Bool
    func clear()
    func add(delegate: KinescopeVideoDownloadableDelegate)
    func remove(delegate: KinescopeVideoDownloadableDelegate)
    func restore()

}

public extension KinescopeVideoDownloadable {

    func isDownloaded(videoId: String) -> Bool {
        return downloadedList().contains(videoId)
    }

    func enqueueDownload(videoId: String, url: URL, video: KinescopeVideo?) {
        enqueueDownload(videoId: videoId, url: url, video: video, minimumHeight: nil)
    }

    func enqueueDownload(videoId: String, url: URL, video: KinescopeVideo?, minimumHeight: Int?) {
        enqueueDownload(videoId: videoId, url: url)
    }

    func posterLocation(by videoId: String) -> URL? {
        nil
    }

}
