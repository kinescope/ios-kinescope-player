# Analytics

The player sends playback events through `Kinescope.shared.analyticFactory` (play, pause, seek, quality change, fullscreen, and the rest of the proto event set). The player version in each event is `Kinescope.sdkVersion`.

Listen without replacing that pipeline:

```swift
Kinescope.shared.setAnalytics(delegate: self)

func didSendAnalytics(event: String, with data: String) {
    // event name and the serialized payload
}
```

`KinescopeAnalyticsDelegate.didSendAnalytics(event:with:)` runs for each event the player emits. Logging those lines is what the example app delegate does via `KinescopeDefaultLogger` and `KinescopeLoggerLevel`.

Quality changes also call `KinescopeVideoPlayerDelegate.player(changedQualityTo:)`.

## Viewer ID

Your own user or account id, sent with every event as `Session.ExternalID`. It is the same as `externalid` in the web embed.

```swift
let player = KinescopeVideoPlayer(config: .init(videoId: id, externalId: "user-42"))
player.externalId = "user-43"   // the next event uses the new value
```

Leading and trailing spaces are dropped. `nil` or a blank string sends nothing.

## Turning analytics off

```swift
let player = KinescopeVideoPlayer(config: .init(videoId: id, doNotTrack: true))
player.doNotTrack = false   // can be switched at any time
```

While `doNotTrack` is on, the player sends no events and `KinescopeAnalyticsDelegate` is not called. It is the same as `dnt` in the web embed.
