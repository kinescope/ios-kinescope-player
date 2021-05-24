# KinescopeAttachmentDownloadableDelegate

Delegate protocol to listen attachments download file process events

``` swift
public protocol KinescopeAttachmentDownloadableDelegate: AnyObject 
```

## Inheritance

`AnyObject`

## Requirements

### attachmentDownloadProgress(attachmentId:​progress:​)

Notify about progress state of downloading task

``` swift
func attachmentDownloadProgress(attachmentId: String, progress: Double)
```

#### Parameters

  - attachmentId: Id of downloading attachment
  - progress: Progress of process

### attachmentDownloadError(attachmentId:​error:​)

Notify about error state of downloading task

``` swift
func attachmentDownloadError(attachmentId: String, error: KinescopeDownloadError)
```

#### Parameters

  - attachmentId: Id of downloading attachment
  - error: Reason of failure

### attachmentDownloadComplete(attachmentId:​url:​)

Notify about successfully completed downloading task

``` swift
func attachmentDownloadComplete(attachmentId: String, url: URL?)
```

#### Parameters

  - attachmentId: Id of downloading attachment
  - url: URL path to cache of saved attachment file, nil if attachment didn't saved
