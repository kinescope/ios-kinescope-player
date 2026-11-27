# Installation

Deployment target is iOS 15. The SDK is Swift. New versions are published as git tags, and the app pulls a tag through Swift Package Manager or CocoaPods (`:git` and `:tag`).

The package has two libraries:

| Product | What is inside |
| --- | --- |
| `KinescopeSDK` | Player, offline HLS downloads with FairPlay, dashboard catalog |
| `KinescopeShorts` | Everything in `KinescopeSDK` plus the vertical Shorts feed (`KinescopeShortsViewController`) |

An app that only plays video takes `KinescopeSDK` and does not ship the Shorts code and images.

CocoaPods Trunk stops accepting new versions and new pods on 2 December 2026. Installs by short name (`pod 'KinescopeSDK', '~> 1.0'`) keep the last version published to Trunk and do not get later releases. Use the git tag form below.

## CocoaPods

CocoaPods gets the player only. Shorts are in the Swift package.

Release, pinned to a tag:

```ruby
platform :ios, '15.0'
use_frameworks!

target 'YourApp' do
  pod 'KinescopeSDK', :git => 'https://github.com/kinescope/ios-kinescope-player.git', :tag => '1.0.4'
end
```

Local development, from a checkout next to your app:

```ruby
pod 'KinescopeSDK', :path => '../ios-kinescope-player'
```

```ruby
pod install
```

Two CocoaPods dependencies (`M3U8Kit` and `SwiftProtobuf`) declare an older minimum iOS than the SDK. Current Xcode rejects those targets, so add this `post_install` block to the app's Podfile:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
```

## Swift Package Manager

In Xcode, add the package `https://github.com/kinescope/ios-kinescope-player.git` with `Exact Version` `1.0.4`, then add one product to the app target:

- `KinescopeSDK` for the player only
- `KinescopeShorts` for the Shorts feed. The player comes with it, so do not add `KinescopeSDK` as well: the player would be linked twice

In `Package.swift` of your own package:

```swift
.package(url: "https://github.com/kinescope/ios-kinescope-player.git", exact: "1.0.4"),

// player only
.product(name: "KinescopeSDK", package: "ios-kinescope-player"),
// or Shorts with the player
.product(name: "KinescopeShorts", package: "ios-kinescope-player"),
```

With `KinescopeShorts`, files that show the feed add `import KinescopeShorts`. Player types still come from `import KinescopeSDK`.

The package lives at the repository root (`Package.swift`, tools 5.3, iOS 15).

## App setup

Call configuration once at launch, before the first player:

```swift
Kinescope.shared.setConfig(KinescopeConfig(apiKey: "<dashboard token>"))
```

A public video plays without an API key. The key is required for `KinescopeDashboard.videos` and for creating player templates.

`KinescopeConfig` also takes `endpoint` (host for `{videoId}.json`, `baseUrl` in the web embed), `referer` (for dashboard domain restrictions), and `userAgent` (`User-Agent` for metadata, stream, and subtitle requests).

## Logger

```swift
Kinescope.shared.set(logger: KinescopeDefaultLogger(),
                     levels: KinescopeLoggerLevel.allCases)
```
