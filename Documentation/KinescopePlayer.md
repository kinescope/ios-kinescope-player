# KinescopePlayer

Control protocol for player

``` swift
public protocol KinescopePlayer 
```

## Requirements

### pipDelegate

Delegate of Picture in Picture controller

``` swift
var pipDelegate: AVPictureInPictureControllerDelegate? 
```

### delegate

Player delegate

``` swift
var delegate: KinescopeVideoPlayerDelegate? 
```

### init(config:​)

``` swift
init(config: KinescopePlayerConfig)
```

  - parameter config: player configuration

### setVideo(\_:​)

Set video model model(if it's already loaded for example)

``` swift
func setVideo(_ video: KinescopeVideo)
```

### play()

Start playing of video

``` swift
func play()
```

### pause()

Pause playing of video

``` swift
func pause()
```

### stop()

Stops playing video

``` swift
func stop()
```

### select(quality:​)

Generate new playerItem with selected quality resource

``` swift
func select(quality: KinescopeVideoQuality)
```

#### Parameters

  - quality: Quality of video to play.

### attach(view:​)

Bind player to view

``` swift
func attach(view: KinescopePlayerView)
```

#### Parameters

  - view: view for binding

### detach(view:​)

Unbind player from view

``` swift
func detach(view: KinescopePlayerView)
```

#### Parameters

  - view: view for unbinding
