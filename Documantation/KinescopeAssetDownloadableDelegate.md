# KinescopeAssetDownloadableDelegate

Delegate protocol to listen assets download process events

``` swift
public protocol KinescopeAssetDownloadableDelegate: AnyObject 
```

## Inheritance

`AnyObject`

## Requirements

### assetDownloadProgress(assetId:​progress:​)

Notify about progress state of downloading task

``` swift
func assetDownloadProgress(assetId: String, progress: Double)
```

#### Parameters

  - assetId: Asset id of concrete video quality
  - progress: Progress of process

### assetDownloadError(assetId:​error:​)

Notify about error state of downloading task

``` swift
func assetDownloadError(assetId: String, error: KinescopeDownloadError)
```

#### Parameters

  - assetId: Asset id of concrete video quality
  - error: Reason of failure

### assetDownloadComplete(assetId:​url:​)

Notify about successfully completed downloading task

``` swift
func assetDownloadComplete(assetId: String, url: URL?)
```

#### Parameters

  - assetId: Asset id of concrete video quality
  - url: URL path to cache of saved asset file, nil if attachment didn't saved
