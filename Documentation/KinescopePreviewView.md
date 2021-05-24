# KinescopePreviewView

Preview View with video title, description, duration, banner and play image

``` swift
public final class KinescopePreviewView: UIView 
```

## Inheritance

`UIView`

## Initializers

### `init(config:delegate:)`

``` swift
public init(config: KinescopePreviewViewConfiguration, delegate: KinescopePreviewViewDelegate? = nil) 
```

### `init?(coder:)`

``` swift
public required init?(coder: NSCoder) 
```

## Properties

### `previewImageView`

``` swift
public private(set) var previewImageView 
```

### `config`

``` swift
public var config: KinescopePreviewViewConfiguration = .default
```

### `delegate`

``` swift
public weak var delegate: KinescopePreviewViewDelegate?
```

## Methods

### `setPreview(with:)`

``` swift
public func setPreview(with model: KinescopePreviewModel) 
```
