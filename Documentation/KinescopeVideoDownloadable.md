# KinescopeVideoDownloadable

Control protocol managing downloading of assets and videos

``` swift
public protocol KinescopeVideoDownloadable: AnyObject 
```

## Inheritance

`AnyObject`

## Default Implementations

### `isDownloaded(videoId:)`

``` swift
func isDownloaded(videoId: String) -> Bool 
```

## Requirements

### enqueueDownload(videoId:​url:​)

Request downloadable link for video and start downloading

``` swift
func enqueueDownload(videoId: String, url: URL)
```

#### Parameters

  - videoId: Video id
  - url: web URL of video

### pauseDownload(videoId:​)

Pause downloading of asset

``` swift
func pauseDownload(videoId: String)
```

#### Parameters

  - videoId: Video id

### resumeDownload(videoId:​)

Resume downloading of asset

``` swift
func resumeDownload(videoId: String)
```

#### Parameters

  - videoId: Video id

### dequeueDownload(videoId:​)

Stop downloading of asset

``` swift
func dequeueDownload(videoId: String)
```

#### Parameters

  - videoId: Video id

### isDownloaded(videoId:​)

Checks that video was downloaded

``` swift
func isDownloaded(videoId: String) -> Bool
```

#### Parameters

  - videoId: Video id

### downloadedList()

Returns list of downloaded video Id's

``` swift
func downloadedList() -> [String]
```

### getLocation(by:​)

Returns downloaded video path from disk

``` swift
func getLocation(by videoId: String) -> URL?
```

#### Parameters

  - videoId: Video id

### delete(videoId:​)

Deletes downloaded asset from disk

``` swift
@discardableResult
    func delete(videoId: String) -> Bool
```

#### Parameters

  - videoId: Video id

### clear()

Deletes all downloaded videos from disk

``` swift
func clear()
```

### add(delegate:​)

Add delegate to notify about download process

``` swift
func add(delegate: KinescopeVideoDownloadableDelegate)
```

#### Parameters

  - delegate: Instance of delegate

### remove(delegate:​)

Remove delegate

``` swift
func remove(delegate: KinescopeVideoDownloadableDelegate)
```

#### Parameters

  - delegate: Instance of delegate

### restore()

Restore downloads which were interrupted by app close

``` swift
func restore()
```
