# KinescopeSpinner

Custom loading indicator

``` swift
public final class KinescopeSpinner: UIView, KinescopeActivityIndicating 
```

## Inheritance

[`KinescopeActivityIndicating`](/Documentation/KinescopeActivityIndicating), `UIView`

## Initializers

### `init(frame:)`

``` swift
public override init(frame: CGRect) 
```

### `init?(coder:)`

``` swift
public required init?(coder aDecoder: NSCoder) 
```

## Properties

### `ringWidth`

``` swift
public var ringWidth: CGFloat = 5
```

### `color`

``` swift
public var color 
```

## Methods

### `draw(_:)`

``` swift
public override func draw(_ rect: CGRect) 
```

### `showLoading(_:)`

``` swift
public func showLoading(_ isLoading: Bool) 
```
