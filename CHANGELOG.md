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
