# KinescopeControlPanelConfiguration

Appearence preferences for control panel with timeline and settings buttons

``` swift
public struct KinescopeControlPanelConfiguration 
```

## Initializers

### `init(tintColor:backgroundColor:preferedHeight:hideOnPlayTimeout:timeIndicator:timeline:optionsMenu:)`

``` swift
public init(tintColor: UIColor,
                backgroundColor: UIColor,
                preferedHeight: CGFloat,
                hideOnPlayTimeout: TimeInterval?,
                timeIndicator: KinescopePlayerTimeindicatorConfiguration,
                timeline: KinescopePlayerTimelineConfiguration,
                optionsMenu: KinescopePlayerOptionsConfiguration) 
```

  - parameter tintColor: Tint Color of buttons and controls
  - parameter backgroundColor: Background color of panel
  - parameter preferedHeight: Height of control panel in points.
  - parameter hideOnPlayTimeout: Can hide control panel when video is playing some time.
    Require value in seconds. Do not use big values.
    Set `nil` to keep control panel always visible.
  - parameter timeIndicator: Appearance of current tme indicator
  - parameter timeline: Appearance of timeline
  - parameter options: Appearance of expandable options menu
