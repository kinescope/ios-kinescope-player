# Analytics

The player sends playback events through `Kinescope.shared.analyticFactory` (play, pause, seek, quality change, fullscreen, and the rest of the proto event set).

Listen without replacing that pipeline:

```swift
Kinescope.shared.setAnalytics(delegate: self)

func didSendAnalytics(event: String, with data: String) {
    // event name and the serialized payload
}
```

`KinescopeAnalyticsDelegate.didSendAnalytics(event:with:)` runs for each event the player emits. Logging those lines is what the example app delegate does via `KinescopeDefaultLogger` and `KinescopeLoggerLevel`.

Quality changes also call `KinescopeVideoPlayerDelegate.player(changedQualityTo:)`.
