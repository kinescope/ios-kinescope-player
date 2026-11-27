# Player options

## Config

`KinescopePlayerConfig`:

| Field | Role |
| --- | --- |
| `videoId` | Dashboard or embed id |
| `looped` | Start again at the end |
| `repeatingMode` | Retry policy for failed loads |
| `localPlaybackURL` | File URL instead of the network stream |
| `drmAuthToken` | `drmauthtoken` for a protected video |
| `externalId` | Viewer id for analytics. See [Analytics](analytics.md#viewer-id) |
| `doNotTrack` | No analytics events. See [Analytics](analytics.md#turning-analytics-off) |
| `autopause` | Pause when another player starts. See below |
| `allowsBackgroundPlayback` | Keep playing in the background. See below |
| `startTime` | Start position in seconds on every load (`t` in the web embed). Ignored for live |
| `background` | Background video: plays on attach, muted, in a loop, without controls. See below |
| `autofocus` | The player view becomes first responder once the video loads, so a hardware keyboard controls it |

Playback after attach:

```swift
player.play()
player.pause()
player.stop()
player.seek(to: 30)
player.setVolume(0)
player.select(quality: .auto(hlsLink: hls))
player.selectQuality(named: "720")   // 720, 720p, auto, audio
player.setPreload("auto")            // none, metadata, auto
player.enterFullscreen()
player.exitFullscreen()
player.enableSubtitles("en")         // title, language code, or nil for the first track
player.disableSubtitles()
```

`currentTime`, `duration`, `playbackSpeed`, `volume`, `isMuted`, `isFullscreen`, `subtitleTitles`, and `selectedSubtitleTitle` are available on `KinescopeVideoPlayer`.

`externalId`, `doNotTrack`, `autopause`, `allowsBackgroundPlayback`, and `startTime` start from the config and can be changed on the player at any time. `startTime` applies to every load of this player: set it to `nil` if the next video should start from the beginning.

## Web embed parameters

| Web embed | iOS |
| --- | --- |
| `t` | `KinescopePlayerConfig(startTime:)` |
| `dnt` | `KinescopePlayerConfig(doNotTrack:)` |
| `autopause` | `KinescopePlayerConfig(autopause:)` |
| `background` | `KinescopePlayerConfig(background:)` |
| `autofocus` | `KinescopePlayerConfig(autofocus:)` |
| `externalid` | `KinescopePlayerConfig(externalId:)` |
| `header` | `setShowsHeader(false)` on the overlay builder, see [Customization](customization.md#hide-single-controls) |
| `transparent` | `setTransparentBackground(true)` on the layout builder, see [Customization](customization.md#transparent-backdrop) |
| `speedbtn` | `playerView.showsPlaybackRateSetting` |
| `disableFiles` | `player.disableOptions([.attachments])` |
| `preload` | `player.setPreload(_:)` |
| `baseUrl` | `KinescopeConfig(endpoint:)`, for the whole app |
| `userAgent` | `KinescopeConfig(userAgent:)`, for the whole app |
| `watermark` | From the dashboard, see [Customization](customization.md#watermark) |

## Background video

```swift
let player = KinescopeVideoPlayer(config: .init(videoId: id, background: true))
player.attach(view: playerView)   // starts playing, muted, in a loop
```

On attach the player sets the view layout to `KinescopePlayerViewConfiguration.background(from:)`: the picture only, no overlay, control panel, Picture in Picture, or fullscreen on rotate. The rest of the view's layout (gravity, poster, colours) stays. Use the same preset yourself for a view without a background player.

## Autopause

```swift
let player = KinescopeVideoPlayer(config: .init(videoId: id, autopause: true))
```

When any player starts, the players that have `autopause` on pause. It is the same as `autopause` in the web embed. Off by default.

## Background playback

```swift
let player = KinescopeVideoPlayer(config: .init(videoId: id, allowsBackgroundPlayback: true))
```

When the app goes to the background, the picture is detached from the view and the sound goes on. It comes back when the app returns. The app needs the `playback` audio session category and the Audio background mode, otherwise iOS stops the sound anyway.

Off by default: the player pauses in the background, unless `isNowPlayingEnabled` or Picture in Picture keeps it going.

## Control-bar buttons

`disableOptions` hides buttons. Cases on `KinescopePlayerOption`:

- `more` — expands the trailing buttons
- `fullscreen`
- `settings`
- `attachments`
- `download`
- `airPlay`
- `subtitles`
- `pip`
- `chapters` — only if the video has chapters
- `playlist` — only after `setPlaylist`
- `custom(id:icon:)`

```swift
player.addCustomPlayerOption(with: "share", and: icon)
player.disableOptions([.airPlay])
```

The SDK does not ship a share button. The example player does not add one either. A host that wants share passes its own image to `addCustomPlayerOption` and handles it in `KinescopeVideoPlayerDelegate.player(didSelectCustomOptionWith:anchoredAt:)`. `config.shareLink` is `https://kinescope.io/<videoId>`.

## Template flags in the example

The Custom Player screen maps the player template onto the native player:

| Setting | Effect |
| --- | --- |
| Autoplay | `play()` after attach |
| Muted | `setVolume(0)` |
| Loop | `KinescopePlayerConfig.looped` |
| Controls | layout with or without the control panel |
| Playsinline | off calls `enterFullscreen()` once the item is ready |
| Preload | `none` (1s buffer), `metadata` (system), `auto` (30s, warm start muted then pause) |
| Quality | `selectQuality(named:)` |
| Keyboard shortcuts | space play/pause, arrows seek ±10s |
| Picture in Picture / Fullscreen | `disableOptions` |
| Playback rate | `showsPlaybackRateSetting` hides the speed row |
| Accent color | `KinescopePlayerViewConfiguration.accentTimeLineAndPlayButton(with:)` |

Those values are posted to `POST/PUT https://api.kinescope.io/v1/players` with these JSON names (`playsinline`, `keyboard_shortcuts`, `playback_rate`, `color`, …).
