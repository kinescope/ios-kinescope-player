# KinescopePlayerTimelineConfiguration

Appearence preferences for timeline

``` swift
public struct KinescopePlayerTimelineConfiguration 
```

## Initializers

### `init(activeColor:inactiveColor:lineHeight:circleRadius:)`

``` swift
public init(activeColor: UIColor,
                inactiveColor: UIColor,
                lineHeight: CGFloat,
                circleRadius: CGFloat) 
```

  - parameter activeColor: Color of circle and line before. Equal to past time or played video part.
  - parameter inactiveColor: Color of line after circle. Equal to future or not played video part.
  - parameter lineHeight: Height of line in points
  - parameter circleRadius: Radius of current position circle

## Properties

### `` `default` ``

``` swift
static let `default`: KinescopePlayerTimelineConfiguration 
```
