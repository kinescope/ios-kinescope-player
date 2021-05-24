# KinescopeActivityIndicating

Abstraction for activity indicator used to indicate process of video downloading

``` swift
public protocol KinescopeActivityIndicating 
```

## Requirements

### showLoading(\_:​)

Comand to display video loading state

``` swift
func showLoading(_ isLoading: Bool)
```

#### Parameters

  - isLoading: If value is `true` than startAnimating view like `UIActivityIndicator`. Otherwise, stopAnimating and hide indicator.
