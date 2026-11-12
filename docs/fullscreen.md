# Fullscreen

Fullscreen starts in two cases:

- the viewer taps the fullscreen button
- the interface is landscape and the device is landscape, and fullscreen is not already presented

Opening a video in portrait does not enter fullscreen. `AppDelegate.supportedInterfaceOrientations` returns the top view controller's mask, so a portrait screen stays portrait through the push. The example video, playlist, download, and shorts screens are portrait.

Leaving landscape while fullscreen is presented exits fullscreen.

```swift
player.enterFullscreen()
```

The presented controller is `KinescopeFullscreenViewController`. Presentation and dismiss do not animate the player rectangle. The player is detached from the inline view and attached to the fullscreen view, then the controller is presented with `animated: false`. If the window orientation already matches the video, nothing else happens. If it does not (a landscape video opened from a portrait screen, and the reverse on the way back), the orientation request runs after the surface is already on the destination view.

On dismiss the player is attached back to the inline view and the controller is dismissed the same way, without a frame animation. Portrait and landscape use this path.

Hide the button with `player.disableOptions([.fullscreen])`.

The Custom Player "Playsinline" switch calls `enterFullscreen()` when it is off and the item becomes ready. That is the native stand-in for the web `playsinline` flag stored on the template.
