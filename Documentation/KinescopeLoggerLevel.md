# KinescopeLoggerLevel

Default logger levels

``` swift
public enum KinescopeLoggerLevel: KinescopeLoggingLevel, Equatable, CaseIterable 
```

## Inheritance

`CaseIterable`, `Equatable`, [`KinescopeLoggingLevel`](/Documentation/KinescopeLoggingLevel)

## Enumeration Cases

### `network`

Network logs

``` swift
case network
```

### `player`

Player logs

``` swift
case player
```

### `storage`

Storage logs

``` swift
case storage
```

### `analytics`

Analytics logs

``` swift
case analytics
```

## Methods

### `part(of:)`

``` swift
public func part(of array: [KinescopeLoggingLevel]) -> Bool 
```
