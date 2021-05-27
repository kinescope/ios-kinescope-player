# KinescopePlayerView

Main player view

``` swift
public class KinescopePlayerView: UIView 
```

## Inheritance

[`ErrorViewDelegate`](/ErrorViewDelegate), [`PlayerControlOutput`](/PlayerControlOutput), [`PlayerOverlayViewDelegate`](/PlayerOverlayViewDelegate), [`ShadowOverlayDelegate`](/ShadowOverlayDelegate), [`SideMenuDelegate`](/SideMenuDelegate), `UIView`

## Properties

### `previewImage`

Preview image view

``` swift
public private(set) var previewImage: UIImageView 
```

## Methods

### `setLayout(with:)`

Set Layout and Appearance Configuration

``` swift
func setLayout(with config: KinescopePlayerViewConfiguration) 
```

#### Parameters

  - config: Configuration of player

### `showOverlay(_:)`

Show/hide player view overlay

``` swift
func showOverlay(_ shown: Bool) 
```

#### Parameters

  - shown: if true - show, hide otherwise
