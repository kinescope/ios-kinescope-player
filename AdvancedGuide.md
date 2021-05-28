<!-- TODO describe player and player view customisation -->

# Configuring UI

There are a bunch of opportunities to configure player appearance. Look `KinescopePlayerViewConfiguration` to find out all options. 

This struct is used in `KinescopePlayerView` `setLayout(with:)` method.

For example, to configure control panel you can:

```swift
let controlPanelConfig = KinescopeControlPanelConfiguration(tintColor: .red,
                                                            backgroundColor: .blue,
                                                            preferedHeight: 45,
                                                            hideOnPlayTimeout: 0.5,
                                                            timeIndicator: .default,
                                                            timeline: .default,
                                                            optionsMenu: .default)

let playerView = KinescopePlayerView()
playerView.setLayout(with: .init(gravity: .resizeAspect, controlPanel: controlPanelConfig))
```

# Preview view

SDK provides `KinescopePreviewView` with video title, description, duration, banner and play image.

You can create it like this:

```swift
let preview = KinescopePreviewView(config: .default, delegate: self)
```

And after set it like this:

```swift
preview.setPreview(with: .init(title: "Video title", subtitle: "Subtitle", duration: 100))
```

# Fullscreen view

`KinescopeFullscreenViewController` can be used to show fullscreen player. And it is already used by KinescopeVideoPlayer when user taps on fullscreen button.

To configure `KinescopeFullscreenViewController` you should provide it player and config `KinescopeFullscreenConfiguration`. If you already have video model it can be done like this:

```swift
let player = KinescopeVideoPlayer(config: .init(videoId: "some id"))
let fullscreenVC = KinescopeFullscreenViewController(player: player, config: .preferred(for: videoModel))
```

Later you can present this view controller however you want(but be carefull with supported interface orientations).

# Logging

For logging network request, player events or something else use `KinescopeDefaultLogger`.

First step is set `KinescopeLoggerLevel` into configuration at application startup:

```swift
Kinescope.shared.set(logger: KinescopeDefaultLogger(), levels: [KinescopeLoggerLevel.network, KinescopeLoggerLevel.player])
```

Use logger like this:

```swift
Kinescope.shared.logger.log(message: "Bad Request", level: KinescopeLoggerLevel.network)
```

or 

```swift
Kinescope.shared.logger.log(error: NSError(), level: KinescopeLoggerLevel.network)
```

Also SDK has opportunity to use custom logger. Just use protocols `KinescopeLoggingLevel`, `KinescopeLogging`.

# Downloading assets(mp4)

`KinescopeServicesProvider` includes `KinescopeAssetDownloadable` which has out-of-box implementation - `AssetDownloader`. 
`KinescopeAssetDownloadable` provides an API to
1) download asset(concrete mp4 file)
2) control dowloading process via pause/resume/cancel(dequeue)
3) delete downloaded asset
4) get downloaded assets list and their paths
5) handle downloading events(progress, completion, error) via KinescopeAssetDownloadableDelegate
6) etc

```swift
Kinescope.shared.assetDownloader.add(delegate: self)
Kinescope.shared.assetDownloader.enqueueDownload(asset: someVideoAsset)
```

`KinescopeAssetDownloadable` uses concrete asset id of some video for downloading and future access.  

`AssetDownloader`(out-of-box implementation of `KinescopeAssetDownloadable`) is based on `URLSession` for downloading files and uses documents directory on disk  for storing downloaded assets, all assets are kept in own directory "KinescopeAssets".

# Downloading video stream(hls)

`KinescopeVideoDownloadable` and `VideoDownloader`

`KinescopeServicesProvider` includes `KinescopeVideoDownloadable` which has out-of-box implementation - `VideoDownloader`. 
`KinescopeVideoDownloadable` provides an API to
1) download video(hls stream)
2) control dowloading process via pause/resume/cancel(dequeue)
3) delete downloaded video
4) get downloaded video list and their paths
5) handle downloading events(progress, completion, error) via KinescopeVideoDownloadableDelegate
6) etc

```swift
Kinescope.shared.videoDownloader.add(delegate: self)
Kinescope.shared.videoDownloader.enqueueDownload(videoId: "someId", url: someVideoURL)
```

`KinescopeVideoDownloadable` uses video id and its url for downloading and future access.  

`VideoDownloader`(out-of-box implementation of `KinescopeAssetDownloadable`) is based on `AVAssetDownloadURLSession` for downloading and UserDefaults for storing paths to downloaded assets. 

# Downloading attachments 

`KinescopeAttachmentDownloadable` and `AttachmentDownloader`

`KinescopeServicesProvider` includes `KinescopeAttachmentDownloadable` which has out-of-box implementation - `AttachmentDownloader`. 
`KinescopeAttachmentDownloadable` provides an API to
1) download attachment
2) control dowloading process via pause/resume/cancel(dequeue)
3) delete downloaded attachment
4) get downloaded attachments list and their paths to cache
5) handle downloading events(progress, completion, error) via KinescopeAttachmentDownloadableDelegate
6) clear all attachments from cache

```swift
Kinescope.shared.attachmentDownloader.add(delegate: self)
Kinescope.shared.attachmentDownloader.enqueueDownload(attachment: someAttachmentModel)
```

`KinescopeAttachmentDownloadable` uses concrete attachment id of some file for downloading and future access.  

`AttachmentDownloader`(out-of-box implementation of `KinescopeAssetDownloadable`) is based on `URLSession` for downloading files and used documents directory on disk  for storing downloaded files, all attachments are kept in own directory "KinescopeAttachments".

# AirPlay, Picture in Picture and background mode

AirPlay lets you share video from Apple devices direct to Apple TV, speakers and popular smart TVs. SDK has out-of-box support of AirPlay. 

Picture in Picture lets you watch a thumbnail-size video play in the corner of your screen while you do other things on your device. As AirPlay, SDK also has out-of-box support of PiP and KinescopePlayer has `AVPictureInPictureController` delegate methods to handle PiP actions. You should keep strong reference to `KinescopePlayer` or `AVPictureInPictureController` in order to keep playing video in PiP.

 To implement this features in project, just set your app’s `AVAudioSession’s` category to AVAudioSession.Category.playback and policy AVAudioSession.RouteSharingPolicy.longForm(can be found in Example project).
 
 To make this features working in background enable "Audio, AirPlay, and Picture in Picture" in Background Modes capability. 
 
 Also with this capability audio from video will be playing after the app enters background. To add audio control you should setup MediaPlayer(example can be found in `setupCommandCenter()` of `VideoViewController` of Example project).

# Handling phone calls

With an incoming call, video will be paused by system, true for background. To resume video, use `didGetCall` method of `KinescopeVideoPlayerDelegate`.

Method will be called on every call action: on end, connect, hold and on outgoing call.

# Localization

To add new localization to strings from SDK, add in your project file "KinescopeLocalizable.strings", file should located in main bundle(it is important to multi-modules projects), copy all content from SDK Localizable.strings file, which is located in KinescopeSDK and add new languages or change values of existing ones. 

# Handling SDK events(for example for analytics) 

`KinescopeServicesProvider` includes `KinescopeEventsCenter` which has out-of-box implementation - `LocalEventsCenter`.

It is used to handle player events(`KinescopeEvent` enum), based on NotificationCenter and has similar API, but with `KinescopeEvent` as a key insead of string.

```swift
Kinescope.shared.eventsCenter.addObserver(self, selector: #selector(handlePlayEvent), event: .play)

@objc
private func handlePlayEvent() {
    // some logic
}
```
