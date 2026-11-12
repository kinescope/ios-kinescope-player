# Installation

Deployment target is iOS 15. The SDK is Swift. New versions are published as git tags, and the app pulls a tag through CocoaPods (`:git` and `:tag`) or Swift Package Manager.

CocoaPods Trunk stops accepting new versions and new pods on 2 December 2026. Installs by short name (`pod 'KinescopeSDK', '~> 1.0'`) keep the last version published to Trunk and do not get later releases. Use the git tag form below.

## CocoaPods

Release, pinned to a tag:

```ruby
platform :ios, '15.0'
use_frameworks!

target 'YourApp' do
  pod 'KinescopeSDK', :git => 'https://github.com/kinescope/ios-kinescope-player.git', :tag => '1.0.2'
end
```

Local development, from a checkout next to your app (the example uses this form):

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

In Xcode, add the package `https://github.com/kinescope/ios-kinescope-player.git` with `Exact Version` `1.0.2`, then add the `KinescopeSDK` product to the app target. The package lives at the repository root (`Package.swift`, tools 5.3, iOS 15). It builds the whole SDK: the player, Shorts, and offline downloads.

## App setup

Call configuration once at launch, before the first player:

```swift
Kinescope.shared.setConfig(KinescopeConfig(apiKey: "<dashboard token>"))
```

A public video plays without an API key. The key is required for `KinescopeDashboard.videos` and for creating player templates.

## Logger

```swift
Kinescope.shared.set(logger: KinescopeDefaultLogger(),
                     levels: KinescopeLoggerLevel.allCases)
```
