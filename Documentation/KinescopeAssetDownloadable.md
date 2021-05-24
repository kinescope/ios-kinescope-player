# KinescopeAssetDownloadable

Control protocol managing downloading of assets(concrete quality)

``` swift
public protocol KinescopeAssetDownloadable: AnyObject 
```

## Inheritance

`AnyObject`

## Requirements

### enqueueDownload(asset:​)

Request downloadable link for asset and start downloading

``` swift
func enqueueDownload(asset: KinescopeVideoAsset)
```

#### Parameters

  - asset: Asset model for concrete video quality

### pauseDownload(assetId:​)

Pause downloading of asset

``` swift
func pauseDownload(assetId: String)
```

#### Parameters

  - assetId: Asset id of concrete video quality

### resumeDownload(assetId:​)

Resume downloading of asset

``` swift
func resumeDownload(assetId: String)
```

#### Parameters

  - assetId: Asset id of concrete video quality

### dequeueDownload(assetId:​)

Stop downloading of asset

``` swift
func dequeueDownload(assetId: String)
```

#### Parameters

  - assetId: Asset id of concrete video quality

### isDownloaded(assetId:​)

Checks that asset of concrete quality was downloaded

``` swift
func isDownloaded(assetId: String) -> Bool
```

#### Parameters

  - assetId: Asset id of concrete video quality

### downloadedList()

Returns list of downloaded assets Id's

``` swift
func downloadedList() -> [URL]
```

### getLocation(by:​)

Returns downloaded asset path from disk

``` swift
func getLocation(by assetId: String) -> URL?
```

#### Parameters

  - assetId: Asset id of concrete video quality

### delete(assetId:​)

Deletes downloaded asset from disk

``` swift
@discardableResult
    func delete(assetId: String) -> Bool
```

#### Parameters

  - assetId: Asset id of concrete video quality

### clear()

Deletes all downloaded assets from disk

``` swift
func clear()
```

### add(delegate:​)

Add delegate to notify about download process

``` swift
func add(delegate: KinescopeAssetDownloadableDelegate)
```

#### Parameters

  - delegate: Instance of delegate

### remove(delegate:​)

Remove delegate

``` swift
func remove(delegate: KinescopeAssetDownloadableDelegate)
```

#### Parameters

  - delegate: Instance of delegate

### restore()

Restore downloads which were interrupted by app close

``` swift
func restore()
```
