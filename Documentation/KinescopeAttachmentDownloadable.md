# KinescopeAttachmentDownloadable

Control protocol managing downloading of attachments

``` swift
public protocol KinescopeAttachmentDownloadable: AnyObject 
```

## Inheritance

`AnyObject`

## Requirements

### enqueueDownload(attachment:​)

Start downloading attachment
Downloading won't start if the attachment already stored on disk

``` swift
func enqueueDownload(attachment: KinescopeVideoAdditionalMaterial)
```

#### Parameters

  - attachment: Attachment's model

### pauseDownload(attachmentId:​)

Pause downloading of attachment

``` swift
func pauseDownload(attachmentId: String)
```

#### Parameters

  - attachmentId: id of attachment's file

### resumeDownload(attachmentId:​)

Resume downloading of attachment

``` swift
func resumeDownload(attachmentId: String)
```

#### Parameters

  - attachmentId: id of attachment's file

### dequeueDownload(attachmentId:​)

Stop downloading of attachment

``` swift
func dequeueDownload(attachmentId: String)
```

#### Parameters

  - attachmentId: id of attachment's file

### isDownloaded(attachmentId:​)

Checks that attachment was downloaded

``` swift
func isDownloaded(attachmentId: String) -> Bool
```

#### Parameters

  - attachmentId: id of attachment's file

### downloadedList()

Returns list of downloaded attachments url's that stored on disk

``` swift
func downloadedList() -> [URL]
```

### getLocation(of:​)

Returns location of downloaded attachment in cache if the file exist, returns nil otherwise

``` swift
func getLocation(of attachmentId: String) -> URL?
```

#### Parameters

  - attachmentId: id of attachment's file

### delete(attachmentId:​)

Deletes downloaded attachment from disk and returns result of deleting

``` swift
@discardableResult
    func delete(attachmentId: String) -> Bool
```

#### Parameters

  - attachmentId: id of attachment's file

### clear()

Deletes all downloaded attachments from disk

``` swift
func clear()
```

### add(delegate:​)

Add delegate to notify about download process

``` swift
func add(delegate: KinescopeAttachmentDownloadableDelegate)
```

#### Parameters

  - delegate: Instance of delegate

### remove(delegate:​)

Remove delegate

``` swift
func remove(delegate: KinescopeAttachmentDownloadableDelegate)
```

#### Parameters

  - delegate: Instance of delegate

### restore()

Restore all download tasks which were interrupted by app close

``` swift
func restore()
```
