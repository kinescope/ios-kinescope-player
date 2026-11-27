## 1.0.4

### Added

- Fullscreen on rotate as its own setting: `KinescopePlayerViewConfiguration.builder().setFullscreenOnRotate(_:)`. Unset, rotation follows the fullscreen button, as before. Portrait videos stay inline on rotation. Leaving fullscreen by the button while the phone is still landscape does not open it again until the phone has been upright
- Fullscreen from code: `exitFullscreen()`, `isFullscreen`, and `KinescopeVideoPlayerDelegate.playerDidEnterFullscreen()` / `playerDidExitFullscreen()`
- Viewer ID in analytics: `KinescopePlayerConfig(externalId:)` and `KinescopeVideoPlayer.externalId`, sent with every event as `Session.ExternalID`, like `externalid` in the web embed
- Turn analytics off: `KinescopePlayerConfig(doNotTrack:)` and `KinescopeVideoPlayer.doNotTrack`, like `dnt` in the web embed
- Autopause: `KinescopePlayerConfig(autopause:)` and `KinescopeVideoPlayer.autopause`. A player that starts pauses the others that have it on
- Background playback: `KinescopePlayerConfig(allowsBackgroundPlayback:)` and `KinescopeVideoPlayer.allowsBackgroundPlayback`. Needs the `playback` audio session category and the background audio mode in the app
- Subtitles from code: `enableSubtitles(_:)` (track title, language code, or the first track), `disableSubtitles()`, `subtitleTitles`, `selectedSubtitleTitle`. Can be called before the video loads
- Hide single controls: `setShowsPlayPauseButton(_:)` on the overlay builder, `setShowsTimeline(_:)` and `setShowsTimeIndicator(_:)` on the control panel builder
- `setShowsDefaultPoster(false)` on the layout builder leaves the view empty when the video has no poster or it fails to load
- Your own images in place of the built-in ones: `setDefaultPoster(_:)` and `setLiveAwaitingCover(_:)` on the layout builder
- Watermark from the server: the player reads `sdk.watermark` from the video metadata and draws it over the picture, in fullscreen and with pinch zoom too. Text, `mode` (`random` jumps around the frame, `stripes` fills it with diagonal rows), `scale`, `display_timeout` (blinking) and `color` (`#RRGGBBAA`). It is set up in the Kinescope dashboard, no code needed. `KinescopePlayerView.watermarkText` returns the current text
- Web embed parameters: `KinescopePlayerConfig(startTime:)` and `KinescopeVideoPlayer.startTime` (`t`), `KinescopePlayerConfig(background:)` (autoplay, muted, loop, no controls), `KinescopePlayerConfig(autofocus:)`, `KinescopeConfig(userAgent:)`, `setShowsHeader(_:)` on the overlay builder (`header`), `setTransparentBackground(_:)` on the layout builder (`transparent`). `baseUrl` is `KinescopeConfig(endpoint:)`
- Quality "Audio" in the settings menu, and `selectQuality(named: "audio")`: the stream switches to its audio rendition (no video is downloaded) and the poster replaces the picture. A downloaded video keeps playing and hides the picture. Shown when the stream has a separate audio rendition or the video is a downloaded file
- Hardware keyboard: space plays or pauses, arrows seek 10 seconds while the player view is first responder. `KinescopePlayerView.keyboardShortcutsEnabled` turns it off
- `Kinescope.sdkVersion`

### Changed

- Shorts moved to their own library, `KinescopeShorts`, in the same Swift package. `KinescopeSDK` is the player, offline downloads, and the dashboard catalog. An app that shows Shorts adds the `KinescopeShorts` product instead of `KinescopeSDK` (the player comes with it) and `import KinescopeShorts` where it opens the feed. The Shorts API is the same. A player-only app needs no change and no longer ships the Shorts code and images. CocoaPods gets the player only. The example app takes the SDK as a local Swift package
- Seek by taps: a double tap on the right or left half seeks 10 seconds, double taps within 1.5 seconds add up. A single tap shows or hides the controls after the double tap timeout. In 1.0.3 a single tap on an outer third seeked at once
- `enterFullscreen()` only opens fullscreen. Before, a second call closed it. Use `exitFullscreen()` to close
- Without the fullscreen button and without the control panel the player in fullscreen still leaves it when the phone turns back to portrait. Before, there was no way out
- Analytics sends `Kinescope.sdkVersion` as the player version. A Swift package build sent `unknown`
- Built-in images are about 10 times smaller: the live cover and the Shorts stub are JPEG, the default poster is a palette PNG. The three images went from 2.45 MB to 217 KB. Resolution and look are the same ([#20](https://github.com/kinescope/ios-kinescope-player/issues/20))

### Fixed

- A downloaded video lists only the rendition picked for the download in the quality menu, without "Auto". Before, it listed every quality of the video, and choosing one switched playback to the network
- The settings badge shows HD only for HD qualities. A portrait video lists 480p with `height` 854 in `quality_map`, and choosing 480p showed HD
- The subtitles button shows the right state after the player view is attached again
- The side menu does not reassign its frames on every player layout

## 1.0.3

### Fixed

- Embedded HLS captions no longer show while subtitles are off. The SDK draws captions itself, and they move down when the seek bar hides.
- Seeking no longer sticks on the loading indicator. Playback lands on the nearest keyframe instead of waiting for an exact sample.
- A tap on either outer third of the video seeks immediately. The center tap still shows and hides the controls.

## 1.0.2

### Fixed

- Swift Package Manager resolution: `M3U8Parser` is pinned to the 1.1.x line. Version 1.2.0 renamed the package to `M3U8Kit`, so `1.0.0` cannot be resolved through SPM. Use `1.0.2` for SPM.

## 1.0.0

### Added

- Playlists (`KinescopePlaylistItem`)
- Chapters for videos, with chapter title shown while scrubbing
- Subtitle styling (`SubtitleStyle`) and captions search
- Now Playing integration (lock screen and Control Center controls)
- Fast seek and double tap seek with accumulated seconds
- Scrub hint header with animated rewind and forward chevrons while seeking via the timeline
- Playback stall watchdog that recovers stalled playback
- Shorts feed in the SDK (`KinescopeShortsViewController`), loaded from the dashboard by `projectId`, `folderId`, and `perPage`
- Shorts UI configuration (`KinescopeShortsUIConfig`, also `KinescopeUiConfig`): hide or replace the side buttons, play mark, seek bar, and stub image, and set button sizes and seek bar colors
- Swift Package Manager distribution (`Package.swift`) with fonts, images, and strings bundled in the package

### Changed

- Icons moved from PNG/PDF to SVG assets
- Licensed under MIT OR Apache-2.0, at the user's option (`LICENSE`, `LICENSE-APACHE`)
- Distributed as git tags. CocoaPods Trunk stops accepting new versions on 2 December 2026

### Fixed

- Playback of downloaded videos (DRM is no longer bound for downloaded `movpkg`)
- Offline DRM fallback by `video.id`
- Seek position fix
- Duplicate playback when leaving the player
- Navigation bar constraints and delete button in the downloads list

## 0.2.2

### Added

- Additional parameter for `KinescopePlayerConfig` to set up repeating attempts count for video loading

### Changed

- Indication of any pauses during playing of video with loading indicator

### Fixed

- Observation of preview/loading/playing status for player config with `looped` enabled
- Restoration of playback after network or stream lost

## 0.2.1

### Fixed bugs

- always default player style in fullscreen mode (now it equal to style of mini-player)

### Removed

- hardcoded endpoint for analytics
- hardcoded endpoint constructor for fairplay

Now ths enpoints provided from server.

## 0.2

### Introduced
- Installation via SPM

### Removed
- APIkey requirement
- API calls including `videoList`
- old example with many videos and scrolling

### Added
- implementation of FairPlayStreaming (DRM)
- animating indicator for live streams
- automatic retry mechanism for video loading
- error state with refresh button
- live stream announce view
- collecting of analytic events with playback data for Kinescope dashboard
- textField in example project to allow user to input videoId
- ability to manage options menu on player view
- ability to listen analytic events in `KinescopeAnalyticsDelegate`
