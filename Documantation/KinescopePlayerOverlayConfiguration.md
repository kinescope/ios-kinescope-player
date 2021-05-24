# KinescopePlayerOverlayConfiguration

Appearence preferences for overlay above video

``` swift
public struct KinescopePlayerOverlayConfiguration 
```

## Initializers

### `init(playImage:pauseImage:replayImage:fastForward:fastBackward:fastForwardImage:fastBackwardImage:backgroundColor:duration:)`

``` swift
public init(playImage: UIImage,
                pauseImage: UIImage,
                replayImage: UIImage,
                fastForward: KinescopeFastRewind,
                fastBackward: KinescopeFastRewind,
                fastForwardImage: UIImage?,
                fastBackwardImage: UIImage?,
                backgroundColor: UIColor,
                duration: TimeInterval) 
```

  - parameter playImage: Image showing If video started after tapping on overlay
  - parameter pauseImage: Image showing If video paused after tapping on overlay
  - parameter replayImage: Image showing If video ended
  - parameter backgroundColor: Background color of overlay
  - parameter animationDuration: Duration of overlay appear animation in seconds
  - parameter fastForward: Time in seconds
  - parameter fastBackward: Time in seconds
  - parameter fastForwardImage: Optionl custom image
  - parameter fastBackwardImage: Optionl custom image
  - parameter duration: Overlay appearing time

## Properties

### `` `default` ``

``` swift
static let `default`: KinescopePlayerOverlayConfiguration 
```
