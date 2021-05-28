# KinescopeFullscreenViewController

View controller with player view over fullscreen

``` swift
final public class KinescopeFullscreenViewController: UIViewController 
```

## Inheritance

`UIViewController`

## Initializers

### `init(player:config:)`

``` swift
public init(player: KinescopePlayer, config: KinescopeFullscreenConfiguration) 
```

  - Parameters:
      - player: Kinescope player instance to manage attach/detach actions
      - config: configuration

## Properties

### `supportedInterfaceOrientations`

``` swift
public override var supportedInterfaceOrientations: UIInterfaceOrientationMask 
```

### `preferredInterfaceOrientationForPresentation`

``` swift
public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation 
```

### `prefersHomeIndicatorAutoHidden`

``` swift
public override var prefersHomeIndicatorAutoHidden: Bool 
```

### `prefersStatusBarHidden`

``` swift
public override var prefersStatusBarHidden: Bool 
```

## Methods

### `viewDidLoad()`

``` swift
public override func viewDidLoad() 
```

### `viewWillAppear(_:)`

``` swift
public override func viewWillAppear(_ animated: Bool) 
```

### `willMove(toParent:)`

``` swift
public override func willMove(toParent parent: UIViewController?) 
```
