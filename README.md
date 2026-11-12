# Kinescope iOS SDK

iOS SDK for [Kinescope](https://kinescope.io/) video: player, vertical Shorts feed, and offline HLS downloads with FairPlay, in one module. Deployment target is iOS 15. Distributed as git tags through CocoaPods (`:git` and `:tag`) and Swift Package Manager.

```ruby
pod 'KinescopeSDK', :git => 'https://github.com/kinescope/ios-kinescope-player.git', :tag => '1.0.2'
```

With CocoaPods, add a `post_install` block that sets `IPHONEOS_DEPLOYMENT_TARGET` to `15.0` for all pods (see [docs/installation.md](docs/installation.md)). Otherwise current Xcode rejects the `M3U8Kit` and `SwiftProtobuf` targets.

CocoaPods Trunk stops accepting new versions on 2 December 2026. The short form `pod 'KinescopeSDK', '~> 1.0'` does not get later releases. See [docs/installation.md](docs/installation.md).

There is no tvOS target.

---

## Documentation

### Getting started

| Topic | File |
|-------|------|
| Features | [docs/features.md](docs/features.md) |
| Installation | [docs/installation.md](docs/installation.md) |
| Quick start | [docs/quick-start.md](docs/quick-start.md) |
| Demo app | [docs/demo-app.md](docs/demo-app.md) |

### Player

| Topic | File |
|-------|------|
| Player options | [docs/player-options.md](docs/player-options.md) |
| Customization (poster, colours, custom button) | [docs/customization.md](docs/customization.md) |
| Live | [docs/live.md](docs/live.md) |
| Local / downloaded playback | [docs/local-playback.md](docs/local-playback.md) |
| Fullscreen | [docs/fullscreen.md](docs/fullscreen.md) |
| Picture-in-Picture | [docs/picture-in-picture.md](docs/picture-in-picture.md) |
| Player chrome (seek bar, zoom, gestures) | [docs/player-chrome.md](docs/player-chrome.md) |
| Settings menu (gear → Quality, Speed, Scale…) | [docs/settings-menu.md](docs/settings-menu.md) |
| Subtitles and captions search | [docs/subtitles-and-settings.md](docs/subtitles-and-settings.md) |
| Analytics | [docs/analytics.md](docs/analytics.md) |

### Dashboard API

| Topic | File |
|-------|------|
| Video list and player templates | [docs/dashboard-api.md](docs/dashboard-api.md) |

### Offline

| Topic | File |
|-------|------|
| HLS download, FairPlay keys, what stays online | [docs/offline-downloads.md](docs/offline-downloads.md) |

### Shorts (vertical feed)

| Topic | File |
|-------|------|
| Open the feed (`KinescopeShortsViewController`) | [docs/demo-app.md](docs/demo-app.md) |
| Look (`KinescopeShortsUIConfig`) | [docs/customization.md](docs/customization.md#shorts) |
| Download a video from the feed | [docs/offline-downloads.md](docs/offline-downloads.md#download-a-short) |

### Changelog

See [CHANGELOG.md](CHANGELOG.md).
