# KinescopeEventsCenter

Interface for events center

``` swift
public protocol KinescopeEventsCenter: AnyObject 
```

## Inheritance

`AnyObject`

## Requirements

### addObserver(\_:​selector:​event:​)

Add observer for event

``` swift
func addObserver(_ observer: Any, selector: Selector, event: KinescopeEvent)
```

#### Parameters

  - observer: Observer object
  - selector: Method selector
  - event: Kinescope event

### removeObserver(\_:​event:​)

Removes observer for event

``` swift
func removeObserver(_ observer: Any, event: KinescopeEvent)
```

#### Parameters

  - observer: Observer object
  - event: Kinescope event

### removeObserver(\_:​)

Removes observer for all events

``` swift
func removeObserver(_ observer: Any)
```

#### Parameters

  - observer: Observer object

### post(event:​userInfo:​)

Posts event

``` swift
func post(event: KinescopeEvent, userInfo: [AnyHashable : Any]?)
```

#### Parameters

  - event: Kinescope event
