# KinescopePlayerConfig

Configuration entity required to connect resource with player

``` swift
public struct KinescopePlayerConfig 
```

## Initializers

### `init(videoId:looped:)`

``` swift
public init(videoId: String, looped: Bool = false) 
```

  - parameter videoId: Id of concrete video. For example from [GET Videos list](https://documenter.getpostman.com/view/10589901/TVCcXpNM)
  - parameter looped: If value is `true` show video in infinite loop. By default is `false`

## Properties

### `videoId`

Id of concrete video. For example from [GET Videos list](https:​//documenter.getpostman.com/view/10589901/TVCcXpNM)

``` swift
public let videoId: String
```

### `looped`

If value is `true` show video in infinite loop.

``` swift
public let looped: Bool
```
