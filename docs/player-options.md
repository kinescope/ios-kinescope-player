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
```

`currentTime`, `duration`, `playbackSpeed`, `volume`, and `isMuted` are available on `KinescopeVideoPlayer`.

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
