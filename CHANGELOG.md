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
