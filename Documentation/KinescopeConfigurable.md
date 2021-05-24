# KinescopeConfigurable

Control protocol supporting connection between SDK and dashboard

``` swift
public protocol KinescopeConfigurable 
```

## Requirements

### setConfig(\_:​)

``` swift
func setConfig(_ config: KinescopeConfig)
```

  - parameter config: Configuration parameters required to connection

### set(logger:​levels:​)

``` swift
func set(logger: KinescopeLogging, levels: [KinescopeLoggingLevel])
```

  - parameter logger: opportunity to set custom logger
  - parameter levels: levels of logging
