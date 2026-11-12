# Customization

`KinescopePlayerView.setLayout(with:)` applies a `KinescopePlayerViewConfiguration`. Builders start from `.default`, so you only override what you need.

## Accent

```swift
playerView.setLayout(with: .accentTimeLineAndPlayButton(with: accent))
```

That sets the timeline active color and the overlay play background. The default accent is `#6161FC`, a purple.

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

The player shows `poster` from the video payload as soon as the inspector returns. `setLayout` must include a preview service (the default layout does). Until then, or when the preview URL cannot be loaded, the view shows `defaultPoster`. Shorts draw their own poster over the player. It stays up until `.playing`, because a layer that was just attached is black for a moment. A neighbour that is already paused on that same cell, with a frame, drops the poster as the page is taken over.

## Shorts

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
