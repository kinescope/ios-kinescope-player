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
Kinescope.shared.inspector.list(request: .init(page: 1),
                                onSuccess: { result in

                                  let videos = result.0
                                  // save video models somewhere

                                  let metaData = result.1
                                  // check metadata
                                })
```

Than init player instance

```
let player = KinescopePlayer(videoId: "some video id")
```

Add player view somewhere in your layout

```
let playerView = KinescopePlayerView()
view.addSubview(playerView)
```

Connect player and playerView together

```
player.attach(view: playerView)
```

Enjoy.

All controls already included into `KinescopePlayerView` and can be hidden optionally.
You can read full [documentation](./DOCUMENTATION.md) or find more examples in our [Example-project](/Example).  

### Logger

For logging network request, player events or something else use `KinescopeDefaultLogger`.

First step is set `KinescopeLoggerLevel` into configuration at application startup:

```swift
Kinescope.shared.set(logger: KinescopeDefaultLogger(), levels: [KinescopeLoggerLevel.network, KinescopeLoggerLevel.player])
```

Use logger like this:

```swift
Kinescope.shared.logger.log(message: "Bad Request", level: KinescopeLoggerLevel.network)
```

or

```swift
Kinescope.shared.logger.log(error: NSError(), level: KinescopeLoggerLevel.network)
```

Also SDK has opportunity to use custom logger. Just use protocols `KinescopeLoggingLevel`, `KinescopeLogging`.

## Installation

Just add KinescopeSDK to your `Podfile` like this

```
pod 'KinescopeSDK' ~> 0.1
```

If you have any issues with method above, than you can specify git repo like this

```
 pod 'KinescopeSDK', :git => 'https://github.com/kinescope/ios-kinescope-player.git'
```

Also you can specify concrete branch or tag if you want

```
 pod 'KinescopeSDK', :git => 'https://github.com/kinescope/ios-kinescope-player.git', :branch => 'master'
```

## Changelog

All notable changes to this project will be documented in [this file](./CHANGELOG.md).

## Issues

For issues, file directly in the [main repo](https://github.com/kinescope/ios-kinescope-player).

## Contribute

If you would like to contribute to the package (e.g. by improving the documentation, solving a bug or adding a cool new feature), please review our [contribution guide](CONTRIBUTING.md) first and send us your pull request.

You PRs are always welcome.

## How to reach us

<!-- TODO add some channel of communication  -->

## License

[MIT License](LICENSE)
