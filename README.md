# Kinescope iOS SDK

[![Pub Version](https://img.shields.io/badge/version-0.1-orange)](https://img.shields.io/badge/version-0.1-orange)

This framework created to help you include [Kinescope](https://kinescope.io/) player into your mobile iOS application.

<!-- TODO add logo here -->

## About

This framework can help you include customizable video player into your mobile application, organize offline playing of your videos.

## Currently supported features

- online and offline playing
- fullscreen, minimal or picture in picture
- customizable UI of player

## Usage

First of all, init SDK with apiKey somewhere at startup of your app

```
Kinescope.shared.setConfig(.init(apiKey: "your api key"))
```

From now you can use most of API through SDK

For example, to get list of videos just call
```
Kinescope.shared.inspector.list(onSuccess: { videos in
  // save video models somewhere
})
```

Than init player instance

```
let player = KinescopePlayer(video_id: "some video id")
```

Add player view somewhere in your layout

```
let playerView = KinescopePlayerView()
view.addSubview(playerView)
```

Connect player and playerView together

```
playerView.player = player
```

Enjoy.

### Logger

For logging network request, player events or something else use `KinescopeLogger`.

First step is set `KinescopeLoggerType` into configuration at application startup:

```swift
Kinescope.shared.set(logingTypes: [KinescopeLoggerType.network, KinescopeLoggerType.player])
```

Use logger like this:

```swift
Kinescope.shared.logger.log(message: "Bad Request", type: KinescopeLoggerType.network)
```

or 

```swift
Kinescope.shared.logger.log(error: NSError(), type: KinescopeLoggerType.network)
```

Also SDK has opportunity to use custom logger. Just use these protocols:

```swift
/// Interface for logging type
public protocol KinescopeLoggingType {
    /// Checks that element is part of array
    /// - Parameter array: array of elements
    func part(of array: [KinescopeLoggingType]) -> Bool
}

/// Interface for logging
public protocol KinescopeLogging {

    /// - Parameter types: types of logging
    init(types: [KinescopeLoggingType])

    /// Log message
    /// - Parameters:
    ///   - message: string message
    ///   - type: type of logging
    func log(message: String, type: KinescopeLoggingType)

    /// Log error
    /// - Parameters:
    ///   - error: error type
    ///   - type: type of logging
    func log(error: Error, type: KinescopeLoggingType)
}
```

## Installation

Just add KinescopeSDK to your `Podfile` like this

```
pod 'KinescopeSDK' ~> 0.1
```

## Changelog

All notable changes to this project will be documented in [this file](./CHANGELOG.md).

## Issues

For issues, file directly in the [main repo](https://github.com/surfstudio/ios-kinescope-sdk).

## Contribute

If you would like to contribute to the package (e.g. by improving the documentation, solving a bug or adding a cool new feature), please review our [contribution guide](CONTRIBUTING.md) first and send us your pull request.

You PRs are always welcome.

## How to reach us

<!-- TODO add some channel of communication  -->

## License

[MIT License](LICENSE)
