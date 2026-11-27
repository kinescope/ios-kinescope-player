# Fullscreen

Fullscreen starts when:

- the viewer taps the fullscreen button
- the phone turns to landscape and rotation is on (see below)
- the app calls `player.enterFullscreen()`

Opening a video in portrait does not enter fullscreen. `AppDelegate.supportedInterfaceOrientations` returns the top view controller's mask, so a portrait screen stays portrait through the push. The example video, playlist, download, and shorts screens are portrait.

## From code

```swift
player.enterFullscreen()   // does nothing if fullscreen is already open
player.exitFullscreen()    // does nothing if this player is not in fullscreen
player.isFullscreen
```

`KinescopeVideoPlayerDelegate` reports both ways in, button, rotation, or code:

```swift
func playerDidEnterFullscreen() { }
func playerDidExitFullscreen() { }
```

Before 1.0.4 `enterFullscreen()` closed fullscreen on a second call. It no longer does.

## Rotation

```swift
playerView.setLayout(with: .builder()
    .setFullscreenOnRotate(true)
    .build())
```

| Value | Turning to landscape |
| --- | --- |
| not set | opens fullscreen only while the fullscreen button is shown (the behaviour before 1.0.4) |
| `true` | opens fullscreen, also without the button or the control panel |
| `false` | never opens fullscreen |

How rotation behaves:

- a portrait video stays inline
- after leaving fullscreen by the button with the phone still landscape, turning to landscape opens it again only after the phone has been upright
- turning back to portrait leaves fullscreen whatever the setting is, so a player without controls is never stuck there
- with the system rotation lock on nothing happens, because iOS does not rotate the interface

Fullscreen follows the interface, not the raw device sensor, so opening a video does not flash a landscape player. That means rotation opens fullscreen only on screens whose app and view controller allow landscape. A portrait-only app opens fullscreen by the button or from code.

## Screens presented full screen

The fullscreen controller of a landscape video supports landscape only. If the player screen sits in a view controller that is itself presented full screen (`modalPresentationStyle = .fullScreen`, for example a `UINavigationController`), that presented controller must not be portrait-only. Otherwise UIKit finds no orientation in common with it once the landscape player is on top, throws `UIApplicationInvalidInterfaceOrientation`, and the app freezes while the sound goes on.

Keep the screen portrait through the app mask instead (`application(_:supportedInterfaceOrientationsFor:)` returning the top controller's mask, as the example does) and let the navigation controller allow landscape:

```swift
func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
    .allButUpsideDown
}
```

A screen shown as a sheet (`.pageSheet`, the default) is not affected.

## Presentation

The presented controller is `KinescopeFullscreenViewController`. Presentation and dismiss do not animate the player rectangle. The player is detached from the inline view and attached to the fullscreen view, then the controller is presented with `animated: false`. If the window orientation already matches the video, nothing else happens. If it does not (a landscape video opened from a portrait screen, and the reverse on the way back), the orientation request runs after the surface is already on the destination view.

On dismiss the player is attached back to the inline view and the controller is dismissed the same way, without a frame animation. Portrait and landscape use this path.

Hide the button with `player.disableOptions([.fullscreen])`. Rotation then follows `setFullscreenOnRotate`; unset, it is off with the button.

The Custom Player "Playsinline" switch calls `enterFullscreen()` when it is off and the item becomes ready. That is the native stand-in for the web `playsinline` flag stored on the template.
