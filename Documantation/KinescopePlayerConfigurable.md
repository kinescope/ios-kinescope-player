# KinescopePlayerConfigurable

Control protocol for configuration of player

``` swift
public protocol KinescopePlayerConfigurable 
```

## Requirements

### setVolume(\_:​)

Set volume of video

``` swift
func setVolume(_ volume: Float)
```

#### Parameters

  - volume: A value of `0.0` indicates silence; a value of `1.0` (the default) indicates full audio volume for the player instance.

### setSpeed(\_:​)

Set speed of video

``` swift
func setSpeed(_ speed: Float)
```

> 

#### Parameters

  - speed: A value of `0.0` pauses the video, while a value of `1.0` plays the current item at its natural rate. Valle **less** than `1.0` will play slow forward. Value **greater** than `1.0` will play fast forward.

### setLoop(enabled:​)

Set loop playing. It means, video will start playing after end

``` swift
func setLoop(enabled: Bool)
```

#### Parameters

  - enabled: `true` to enable loop, or` false` to disable
