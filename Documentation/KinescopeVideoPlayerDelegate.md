# KinescopeVideoPlayerDelegate

Player delegate protocol

``` swift
public protocol KinescopeVideoPlayerDelegate: AnyObject 
```

## Inheritance

`AnyObject`

## Default Implementations

### `playerDidPlay()`

``` swift
func playerDidPlay() 
```

### `playerDidLoadVideo(error:)`

``` swift
func playerDidLoadVideo(error: Error?) 
```

### `playerDidPause()`

``` swift
func playerDidPause() 
```

### `playerDidStop()`

``` swift
func playerDidStop() 
```

### `player(playbackPositionMovedTo:)`

``` swift
func player(playbackPositionMovedTo time: TimeInterval) 
```

### `player(playbackBufferMovedTo:)`

``` swift
func player(playbackBufferMovedTo time: TimeInterval) 
```

### `player(changedStatusTo:)`

``` swift
func player(changedStatusTo status: AVPlayer.Status) 
```

### `player(changedItemStatusTo:)`

``` swift
func player(changedItemStatusTo status: AVPlayerItem.Status) 
```

### `player(changedTimeControlStatusTo:)`

``` swift
func player(changedTimeControlStatusTo status: AVPlayer.TimeControlStatus) 
```

### `player(changedPresentationSizeTo:)`

``` swift
func player(changedPresentationSizeTo size: CGSize) 
```

### `player(didSeekTo:)`

``` swift
func player(didSeekTo time: TimeInterval) 
```

### `player(timelinePositionMovedTo:)`

``` swift
func player(timelinePositionMovedTo position: Double) 
```

### `player(didFastForwardTo:)`

``` swift
func player(didFastForwardTo time: TimeInterval) 
```

### `player(didFastBackwardTo:)`

``` swift
func player(didFastBackwardTo time: TimeInterval) 
```

### `player(changedQualityTo:)`

``` swift
func player(changedQualityTo quality: String) 
```

### `didGetCall(callState:)`

``` swift
func didGetCall(callState: KinescopeCallState) 
```

## Requirements

### playerDidPlay()

Triggered on successfull play action

``` swift
func playerDidPlay()
```

### playerDidLoadVideo(error:​)

Triggered on video load finish with error(error == nil means no error)

``` swift
func playerDidLoadVideo(error: Error?)
```

### playerDidPause()

Triggered on pause action

``` swift
func playerDidPause()
```

### playerDidStop()

Triggered on stop action

``` swift
func playerDidStop()
```

### player(playbackPositionMovedTo:​)

Triggered on AVPlayer playback position change

``` swift
func player(playbackPositionMovedTo time: TimeInterval)
```

### player(playbackBufferMovedTo:​)

Triggered on AVPlayer buffer position change

``` swift
func player(playbackBufferMovedTo time: TimeInterval)
```

### player(changedStatusTo:​)

Triggered on AVPlayer status change

``` swift
func player(changedStatusTo status: AVPlayer.Status)
```

### player(changedItemStatusTo:​)

Triggered on AVPlayer item status change

``` swift
func player(changedItemStatusTo status: AVPlayerItem.Status)
```

### player(changedTimeControlStatusTo:​)

Triggered on AVPlayer TimeControlStatus change

``` swift
func player(changedTimeControlStatusTo status: AVPlayer.TimeControlStatus)
```

### player(changedPresentationSizeTo:​)

Triggered on AVPlayer PresentationSize change

``` swift
func player(changedPresentationSizeTo size: CGSize)
```

### player(didSeekTo:​)

Triggered on force seek to time

``` swift
func player(didSeekTo time: TimeInterval)
```

### player(timelinePositionMovedTo:​)

Triggered on scrabbing along timeline

``` swift
func player(timelinePositionMovedTo position: Double)
```

### player(didFastForwardTo:​)

Triggered on fast forward action

``` swift
func player(didFastForwardTo time: TimeInterval)
```

### player(didFastBackwardTo:​)

Triggered on fast backward action

``` swift
func player(didFastBackwardTo time: TimeInterval)
```

### player(changedQualityTo:​)

Triggered on quality change

``` swift
func player(changedQualityTo quality: String)
```

### didGetCall(callState:​)

Triggered on phone call actions

``` swift
func didGetCall(callState: KinescopeCallState)
```
