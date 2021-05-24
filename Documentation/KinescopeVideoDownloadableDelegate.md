# KinescopeVideoDownloadableDelegate

Delegate protocol to listen videos download process events

``` swift
public protocol KinescopeVideoDownloadableDelegate: AnyObject 
```

## Inheritance

`AnyObject`

## Requirements

### videoDownloadProgress(videoId:​progress:​)

Notify about progress state of downloading task

``` swift
func videoDownloadProgress(videoId: String, progress: Double)
```

#### Parameters

  - videoId: Video id
  - progress: Progress of process

### videoDownloadError(videoId:​error:​)

Notify about error state of downloading task

``` swift
func videoDownloadError(videoId: String, error: KinescopeDownloadError)
```

#### Parameters

  - videoId: Video id
  - error: Reason of failure

### videoDownloadComplete(videoId:​)

Notify about successfully completed downloading task

``` swift
func videoDownloadComplete(videoId: String)
```

#### Parameters

  - videoId: Video id
