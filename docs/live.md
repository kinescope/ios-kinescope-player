# Live

Pass the live video id the same way as VOD:

```swift
let player = KinescopeVideoPlayer(config: .init(videoId: liveId))
player.attach(view: playerView)
player.play()
```

The example uses `aLJgR9TJfe2EUBejpH5Fuo`.

When the inspector marks the video as live:

- the duration suffix stays hidden
- the live indicator is shown in the time slot

Seek on a live stream is limited to the seekable range `duration` reports (the end of that range). Chapters are not shown for live.
