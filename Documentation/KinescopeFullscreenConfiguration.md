# KinescopeFullscreenConfiguration

Appearence preferences for title and subtitle above video

``` swift
public struct KinescopeFullscreenConfiguration 
```

## Initializers

### `init(orientation:orientationMask:backgroundColor:)`

``` swift
public init(orientation: UIInterfaceOrientation, orientationMask: UIInterfaceOrientationMask, backgroundColor: UIColor) 
```

  - Parameters:
      - orientation: Preferred orientation of fullscreenController
      - orientationMask: Supported orientations mask for fullscreenController
      - backgroundColor: Color for background

## Properties

### `landscape`

``` swift
static let landscape: KinescopeFullscreenConfiguration 
```

### `portrait`

``` swift
static let portrait: KinescopeFullscreenConfiguration 
```

## Methods

### `orientations(for:)`

``` swift
static func orientations(for video: KinescopeVideo?) -> UIInterfaceOrientationMask 
```

### `preferred(for:)`

``` swift
static func preferred(for video: KinescopeVideo?) -> KinescopeFullscreenConfiguration 
```
