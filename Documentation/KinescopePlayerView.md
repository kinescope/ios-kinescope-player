# KinescopePlayerView

Main player view

``` swift
public class KinescopePlayerView: UIView 
```

## Inheritance

[`ErrorViewDelegate`](/Documentation/ErrorViewDelegate), [`PlayerControlOutput`](/Documentation/PlayerControlOutput), [`PlayerOverlayViewDelegate`](/Documentation/PlayerOverlayViewDelegate), [`ShadowOverlayDelegate`](/Documentation/ShadowOverlayDelegate), [`SideMenuDelegate`](/Documentation/SideMenuDelegate), `UIView`

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
