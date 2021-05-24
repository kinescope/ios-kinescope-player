# KinescopeServicesProvider

Provider of services working with kinescope api and events

``` swift
public protocol KinescopeServicesProvider 
```

## Requirements

### config

Config for sdk

``` swift
var config: KinescopeConfig! 
```

### assetDownloader

Service managing downloading of assets

``` swift
var assetDownloader: KinescopeAssetDownloadable! 
```

### attachmentDownloader

Service managing downloading of attachments

``` swift
var attachmentDownloader: KinescopeAttachmentDownloadable! 
```

### inspector

Service managing inspectations of dashboard content like videos, projects etc

``` swift
var inspector: KinescopeInspectable! 
```

### logger

Service managing logging process

``` swift
var logger: KinescopeLogging? 
```

### eventsCenter

Events center

``` swift
var eventsCenter: KinescopeEventsCenter! 
```
