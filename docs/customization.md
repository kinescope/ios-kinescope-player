# Customization

`KinescopePlayerView.setLayout(with:)` applies a `KinescopePlayerViewConfiguration`. Builders start from `.default`, so you only override what you need.

## Accent

```swift
playerView.setLayout(with: .accentTimeLineAndPlayButton(with: accent))
```

That sets the timeline active color and the overlay play background. The default accent is `#6161FC`, a purple.

## Watermark

The watermark is set up in the Kinescope dashboard for the player template, not in code. The player gets it from the video metadata (`sdk.watermark`) and draws it over the picture, including fullscreen, pinch zoom, and offline playback of a saved video. A video without a watermark shows nothing.

| Field | Meaning | Default |
| --- | --- | --- |
| `text` | Watermark text. Empty: no watermark | — |
| `mode` | `random`: the text jumps to a new place every 6 seconds. `stripes`: diagonal rows over the whole picture | `random` |
| `scale` | Text width as a share of the picture width, 0–1 | `0.25` |
| `display_timeout` | Blinking, in milliseconds: a number (same show and hide time) or `{"visible": …, "hidden": …}`. `0` or absent: always shown | always shown |
| `color` | CSS colour `#RGB`, `#RGBA`, `#RRGGBB` or `#RRGGBBAA` (the last byte is opacity) | white at 40% |

Read the current text, for logs or tests:

```swift
let text = playerView.watermarkText   // nil when there is no watermark
```

The parsed value is also on the video: `video.analytic?.watermark` (`KinescopeWatermark`). There is no client-side watermark setting: the server value is always used.

## Hide single controls

```swift
playerView.setLayout(with: .builder()
    .setOverlay(.builder().setShowsPlayPauseButton(false).build())
    .setControlPanel(
        .builder()
            .setShowsTimeline(false)
            .setShowsTimeIndicator(false)
            .build()
    )
    .build())
```

| Builder | Method | Hides |
| --- | --- | --- |
| overlay | `setShowsPlayPauseButton(false)` | center play/pause button. A tap there then shows or hides the controls |
| overlay | `setShowsHeader(false)` | video title and description at the top (`header` in the web embed) |
| control panel | `setShowsTimeline(false)` | seek bar |
| control panel | `setShowsTimeIndicator(false)` | current time and duration. The seek bar starts at the left edge. The live badge stays |

Buttons on the right of the bar are hidden with `player.disableOptions`. See [Player options](player-options.md#control-bar-buttons). `setOverlay(nil)` and `setControlPanel(nil)` remove the whole overlay or bar.

## Transparent backdrop

```swift
playerView.setLayout(with: .builder()
    .setTransparentBackground(true)
    .build())
```

The backdrop behind the picture and the poster is clear instead of black, so the screen behind the player shows through the letterbox (`transparent` in the web embed). Fullscreen keeps its black background.

## Timeline only

```swift
playerView.setLayout(with: .builder()
    .setControlPanel(
        .builder()
            .setTimeline(
                .builder()
                    .setActiveColor(color)
                    .setInactiveColor(track)
                    .setLineHeight(4)
                    .build()
            )
            .build()
    )
    .build())
```

## Poster

The player shows `poster` from the video payload as soon as the inspector returns. `setLayout` must include a preview service (the default layout does). Until then, or when the preview URL cannot be loaded, the view shows `defaultPoster`.

Turn the built-in poster off to keep the view empty in those cases:

```swift
playerView.setLayout(with: .builder()
    .setShowsDefaultPoster(false)
    .build())
```

The video's own poster is still shown.

Use your own images in place of the built-in ones:

```swift
playerView.setLayout(with: .builder()
    .setDefaultPoster(UIImage(named: "brandPoster"))
    .setLiveAwaitingCover(UIImage(named: "brandLiveCover"))
    .build())
```

| Method | Shown | `nil` |
| --- | --- | --- |
| `setDefaultPoster(_:)` | when the video has no poster, or it fails to load | built-in `defaultPoster` |
| `setLiveAwaitingCover(_:)` | while a live broadcast has not started | built-in `liveAwaitingCover` |

`setShowsDefaultPoster(false)` wins over `setDefaultPoster(_:)`. The Shorts stub is set with `KinescopeShortsUIConfig.preloadImage`. Shorts draw their own poster over the player. It stays up until `.playing`, because a layer that was just attached is black for a moment. A neighbour that is already paused on that same cell, with a frame, drops the poster as the page is taken over.

## Shorts

Shorts are in the `KinescopeShorts` library, see [Installation](installation.md#swift-package-manager). Import it next to the SDK:

```swift
import KinescopeSDK
import KinescopeShorts
```

`KinescopeShortsViewController` reads `KinescopeShortsUIConfig` (also available as `KinescopeUiConfig`, the same type) when its cells are built. Set the values before the feed is shown. Each property is optional. `nil` keeps the default, and `false` hides that control.

```swift
KinescopeShortsUIConfig.showCommentButton = false
KinescopeShortsUIConfig.actionButtonSize = 28
KinescopeShortsUIConfig.playButtonSize = 46
KinescopeShortsUIConfig.seekBarProgressColor = .white
KinescopeShortsUIConfig.seekBarTrackColor = UIColor.white.withAlphaComponent(0.32)
```

| Property | Type | Default | Effect |
| --- | --- | --- | --- |
| `showLikeButton` | `Bool?` | shown | Like button in the side column |
| `showDislikeButton` | `Bool?` | shown | Dislike button |
| `showCommentButton` | `Bool?` | shown | Comment button |
| `showShareButton` | `Bool?` | shown | Share button |
| `showPlayButton` | `Bool?` | shown | Centre play mark while paused. Tapping the video still pauses and resumes |
| `showSeekBar` | `Bool?` | shown | Bottom scrub bar, its drag area, and the time chip |
| `showPreloadImage` | `Bool?` | shown | Stub image while the poster is missing. `false` leaves the page black until the poster or first frame |
| `likeButtonIcon`, `dislikeButtonIcon`, `commentButtonIcon`, `shareButtonIcon` | `UIImage?` | SDK icons | Replaces the side button icon. Rendered as a template, so it takes the tint |
| `playButtonIcon` | `UIImage?` | SDK icon | Replaces the centre play mark |
| `preloadImage` | `UIImage?` | `shortsStub` | Replaces the stub. Ignored when `showPreloadImage` is `false` |
| `actionButtonSize` | `CGFloat?` | 34 | Side button width and height, in points |
| `playButtonSize` | `CGFloat?` | 62 × 60 | Centre play mark size, in points. A value sets both width and height |
| `seekBarProgressColor` | `UIColor?` | `#6161FC` | Filled part of the scrub bar |
| `seekBarTrackColor` | `UIColor?` | white at 32% | Unfilled part of the scrub bar |

Sizes are in points. The defaults keep the current look, so an app that sets nothing sees no change.

Shorts have no download or saved-videos buttons, so `KinescopeShortsUIConfig` has no options for them. Download a video from the feed by its id; see [Offline downloads](offline-downloads.md#download-a-short).

## Side menu colors

`KinescopeSideMenuConfiguration` and `KinescopeSideMenuItemConfiguration` set the menu background, title font, and the secondary value color (the chapter clock uses that value color, 12pt, white at 64% opacity).
