# Features

| Feature | What you use |
| --- | --- |
| Player | `KinescopeVideoPlayer` and `KinescopePlayerView`. HLS, live, FairPlay, local file playback |
| Chrome | Seek bar with chapter gaps, time with a duration suffix, settings slide, captions search, playlist sheet, pinch zoom 1×–5× clipped to the frame |
| Chapters | Menu rows `1. Title` and a clock on the right (`0:45` or `1:02:03`) |
| Subtitles | In-player cues, style (font, color, size, background), search that stays open and highlights the chosen line |
| Picture in Picture | `KinescopePlayerOption.pip` and `AVPictureInPictureController` |
| Fullscreen | Fullscreen button. The surface switches with no frame animation; rotation runs only when the window orientation does not match the video |
| Dashboard | `KinescopeDashboard.videos` — `GET /v1/videos` |
| Player templates | Example Custom Player saves the settings JSON (`autoplay`, `preload`, `quality`, `color`, …) |
| Shorts | `KinescopeShortsViewController` in this SDK. Look set by `KinescopeShortsUIConfig`. Poster until playback, or the prepared frame when that player is already on the page. Neighbours buffer after the page stops |
| Offline | `Kinescope.shared.videoDownloader`, one HLS rendition, FairPlay persistent key, saved metadata and poster. Subtitles and quality changes stay online |
| Analytics | `KinescopeAnalyticsDelegate` |
| Demo | `Example/` — playlist, subtitles, chapters, DRM, custom player, live, shorts, saved videos |

There is no tvOS player.
