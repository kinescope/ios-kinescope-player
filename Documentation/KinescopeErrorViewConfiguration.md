# KinescopeErrorViewConfiguration

Appearence preferences for timeline

``` swift
public struct KinescopeErrorViewConfiguration 
```

## Initializers

### `init(backgroundColor:image:titleColor:titleFont:subtitleColor:subtitleFont:refreshTitleColor:refreshTitleFont:refreshCornerRadius:refreshBorderColor:refreshBorderWidth:)`

``` swift
public init(backgroundColor: UIColor,
                image: UIImage,
                titleColor: UIColor,
                titleFont: UIFont,
                subtitleColor: UIColor,
                subtitleFont: UIFont,
                refreshTitleColor: UIColor,
                refreshTitleFont: UIFont,
                refreshCornerRadius: CGFloat = 4,
                refreshBorderColor: UIColor,
                refreshBorderWidth: CGFloat = 1) 
```

  - parameter backgroundColor: Color for background
  - parameter image: image for error state
  - parameter titleColor: Text color of title label
  - parameter titleFont: Text font of title label
  - parameter subtitleColor: Text color of subtitle label
  - parameter subtitleFont: Text font of subtitle label
  - parameter refreshTitleColor: Text color of refresh button
  - parameter refreshTitleFont: Text font of refresh button
  - parameter refreshCornerRadius: Corner radius of refresh button in points
  - parameter refreshBorderColor: Color of refresh button border
  - parameter refreshBorderWidth: Width of refresh button border in points

## Properties

### `` `default` ``

``` swift
static let `default`: KinescopeErrorViewConfiguration 
```
