# KinescopeLogging

Interface for logging

``` swift
public protocol KinescopeLogging 
```

## Requirements

### log(message:​level:​)

Log message

``` swift
func log(message: String, level: KinescopeLoggingLevel)
```

#### Parameters

  - message: string message
  - type: type of logging

### log(error:​level:​)

Log error

``` swift
func log(error: Error, level: KinescopeLoggingLevel)
```

#### Parameters

  - error: error type
  - type: type of logging
