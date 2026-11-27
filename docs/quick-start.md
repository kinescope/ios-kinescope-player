# Quick start

Add the package first, see [Installation](installation.md). Files that use the player start with:

```swift
import KinescopeSDK
```

## 1. Configure the SDK

```swift
func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    Kinescope.shared.setConfig(KinescopeConfig(apiKey: "<dashboard token>"))
    return true
}
```

## 2. Add a player view

```swift
let playerView = KinescopePlayerView()
playerView.setLayout(with: .default)
view.addSubview(playerView)
```

`setLayout(with:)` builds the chrome. Call it once the screen is on screen if the push animation must stay smooth. Building the control bar during `viewDidLoad` stalls the transition.

## 3. Create the player and play

```swift
let player = KinescopeVideoPlayer(config: .init(videoId: videoId))
player.setDelegate(delegate: self)
player.attach(view: playerView)
player.play()
```

Stop and detach when the screen goes away:

```swift
player.pause()
player.stop()
player.detach(view: playerView)
```

## 4. Hide buttons you do not want

```swift
player.disableOptions([.airPlay, .download])
```

## Loop, offline file, DRM token

```swift
KinescopePlayerConfig(videoId: videoId,
                      looped: true,
                      localPlaybackURL: fileURL,
                      drmAuthToken: token)
```

`drmAuthToken` is sent as `drmauthtoken` on the video metadata request.

## Shorts

With the `KinescopeShorts` product the feed is one view controller. It loads the videos of a dashboard project or folder (`nil` is no filter):

```swift
import KinescopeSDK
import KinescopeShorts

let shorts = KinescopeShortsViewController(projectId: projectId, folderId: nil, perPage: 100)
navigationController?.pushViewController(shorts, animated: true)
```

The feed needs `Kinescope.shared.setConfig` with the dashboard token from step 1. Its look is set by `KinescopeShortsUIConfig`, see [Customization](customization.md#shorts).
