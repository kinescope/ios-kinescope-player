# KinescopeVideoPlayer

KinescopePlayer implementation

``` swift
public class KinescopeVideoPlayer: NSObject, KinescopePlayer 
```

## Inheritance

[`KinescopePlayer`](/KinescopePlayer), [`KinescopePlayerConfigurable`](/KinescopePlayerConfigurable), [`KinescopePlayerViewDelegate`](/KinescopePlayerViewDelegate), [`CallObserverDelegate`](/CallObserverDelegate), `NSObject`, [`PlaybackManagerDelegate`](/PlaybackManagerDelegate)

## Initializers

### `init(config:)`

``` swift
public required convenience init(config: KinescopePlayerConfig) 
```

## Properties

### `pipDelegate`

``` swift
public weak var pipDelegate: AVPictureInPictureControllerDelegate? 
```

### `delegate`

``` swift
public weak var delegate: KinescopeVideoPlayerDelegate?
```

## Methods

### `setVideo(_:)`

``` swift
public func setVideo(_ video: KinescopeVideo) 
```

### `play()`

``` swift
public func play() 
```

### `pause()`

``` swift
public func pause() 
```

### `stop()`

``` swift
public func stop() 
```

### `attach(view:)`

``` swift
public func attach(view: KinescopePlayerView) 
```

### `detach(view:)`

``` swift
public func detach(view: KinescopePlayerView) 
```

### `select(quality:)`

``` swift
public func select(quality: KinescopeVideoQuality) 
```

### `observeValue(forKeyPath:of:change:context:)`

``` swift
public override func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey : Any]?,
                                      context: UnsafeMutableRawPointer?) 
```

### `set(speed:)`

``` swift
public func set(speed: KinescopePlayerSpeed) 
```

### `set(muted:)`

``` swift
public func set(muted: Bool) 
```
