# KinescopePlayerConfigurable

Control protocol for configuration of player

``` swift
public protocol KinescopePlayerConfigurable 
```

## Requirements

### set(speed:​)

Set speed of video

``` swift
func set(speed: KinescopePlayerSpeed)
```

#### Parameters

  - speed: Speed options enum

### set(muted:​)

Set mute on player

``` swift
func set(muted: Bool)
```

#### Parameters

  - muted: `true` to mute, or` false` to unmmute
