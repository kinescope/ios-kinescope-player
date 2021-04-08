<!-- TODO describe player and player view customisation -->

# KinescopeAssetDownloadable and AssetDownloader

KinescopeServicesProvider includes KinescopeAssetDownloadable which has out-of-box implementation - AssetDownloader. It is used to download video assets, to track downloading progression and to get acces to downloaded files.

KinescopeAssetDownloadable API looks like this:
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
func add(delegate: KinescopeAssetDownloadableDelegate)

/// Remove delegate
///
/// - parameter delegate: Instance of delegate 
func remove(delegate: KinescopeAssetDownloadableDelegate)

/// Restore downloads which were interrupted by app close
func restore()

```

KinescopeAssetDownloadableDelegate is used to handle KinescopeAssetDownloadable events: 

```swift
/// Delegate protocol to listen download process events
public protocol KinescopeAssetDownloadableDelegate: class {

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

AssetDownloader(out-of-box implementation of KinescopeAssetDownloadable) is based on AVAssetDownloadURLSession for downloading and UserDefaults for storing paths to downloaded assets. 
