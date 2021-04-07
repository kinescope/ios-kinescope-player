<!-- TODO describe player and player view customisation -->

# KinescopeDownloadable and VideoDownloader

KinescopeServicesProvider includes KinescopeDownloadable which has out-of-box implementation - VideoDownloader. It is used to download video assets, to track downloading progression and to get acces to downloaded files.

KinescopeDownloadable API looks like this:
```swift

/// Checks that asset was downloaded
///
/// - parameter assetId: Asset id of concrete video quality
func isDownloaded(assetId: String) -> Bool

/// Returns list of downloaded assets Id's
func downlaodedAssetsList() -> [String]

/// Deletes downloaded asset from disk
///
/// - parameter assetId: Asset id of concrete video quality
@discardableResult
func delete(assetId: String) -> Bool

/// Deletes all downloaded assets from disk
func clear()

/// Returns downloaded asset path from disk
///
/// - parameter assetId: Asset id of concrete video quality
func getPath(by assetId: String) -> URL?

/// Request downloadable link for asset and start downloading
///
/// - parameter assetId: Asset id of concrete video quality
func enqeueDownload(assetId: String)

/// Pause downloading of asset
///
/// - parameter assetId: Asset id of concrete video quality
func pauseDownload(assetId: String)

/// Resume downloading of asset
///
/// - parameter assetId: Asset id of concrete video quality
func resumeDownload(assetId: String)

/// Stop downloading of asset
///
/// - parameter assetId: Asset id of concrete video quality
func deqeueDownload(assetId: String)

/// Add delegate to notify about download process
///
/// - parameter delegate: Instance of delegate
func add(delegate: KinescopeDownloadableDelegate)

/// Remove delegate
///
/// - parameter delegate: Instance of delegate 
func remove(delegate: KinescopeDownloadableDelegate)

/// Restore downloads which were interrupted by app close
func restore()

```

KinescopeDownloadableDelegate is used to handle KinescopeDownloadable events: 

```swift
/// Delegate protocol to listen download process events
public protocol KinescopeDownloadableDelegate: class {

    /// Notify about progress state of downloading task
    ///
    /// - parameter assetId: Asset id of concrete video quality
    /// - parameter progress: Progress of process
    func kinescopeDownloadProgress(assetId: String, progress: Double)

    /// Notify about error state of downloading task
    ///
    /// - parameter assetId: Asset id of concrete video quality
    /// - parameter error: Reason of failure
    func kinescopeDownloadError(assetId: String, error: KinescopeDownloadError)

    /// Notify about successfully completed downloading task
    ///
    /// - parameter assetId: Asset id of concrete video quality
    func kinescopeDownloadComplete(assetId: String)

}
```

VideoDownloader(out-of-box implementation of KinescopeDownloadable) is based on AVAssetDownloadURLSession for downloading and UserDefaults for storing paths to downloaded assets. 
