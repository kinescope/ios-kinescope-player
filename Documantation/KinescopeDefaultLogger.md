# KinescopeDefaultLogger

Default KinescopeLogging implementation. Based on standard output print() method

``` swift
public final class KinescopeDefaultLogger: KinescopeLogging 
```

## Inheritance

[`KinescopeLogging`](/KinescopeLogging)

## Initializers

### `init()`

``` swift
public init() 
```

## Methods

### `log(message:level:)`

Logs simple string message

``` swift
public func log(message: String, level: KinescopeLoggingLevel) 
```

#### Parameters

  - message: String message
  - level: Loggel level

### `log(error:level:)`

Logs error

``` swift
public func log(error: Error, level: KinescopeLoggingLevel) 
```

#### Parameters

  - error: Error
  - level: Loggel level
