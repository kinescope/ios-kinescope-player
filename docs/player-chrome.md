# Player chrome

`playerView.setLayout(with: .default)` installs the default control bar.

## Timeline

The bar is a thin rounded track. Played color is the accent (default purple). Chapter starts split the bar with a small gap. Scrubbing grows the thumb. A tap on the time label reveals ` / duration` over 100ms: the suffix stays transparent until 40% of the animation, then fades in. Expanding the more-buttons fades the time in place and shrinks the seek bar; it does not squash the glyphs.

## Chapters

The chapters button opens a list. Each row is `1. Title` on the left and the start clock on the right: `0:45`, or `1:02:03` when the start is an hour or more. `0:00` is used for a start at zero. Choosing a row seeks and closes the menu.

While scrubbing, the chapter title sits above the bar.

## Playlist

`player.setPlaylist(_:currentItemId:)` shows the playlist button. The in-player sheet lists the items. The example Playlist test is a separate screen: a 211pt player on top and the dashboard catalog underneath. It does not autoplay the first row.

## Taps


- a double tap on the right half seeks 10 seconds forward, on the left half 10 seconds back
- double taps on the same side within 1.5 seconds add up, and the badge shows the total (`+20`, `+30`)
- a single tap shows or hides the controls. It waits for the double tap timeout first
- the center play/pause button reacts at once, and a double tap on it does not seek

With `setOverlay(nil)` there are no taps on the video at all.

## Hardware keyboard

While the player view is first responder, space plays or pauses and the left and right arrows seek 10 seconds. `KinescopePlayerConfig(autofocus: true)` makes the view first responder once the video loads; otherwise call `playerView.becomeFirstResponder()`. Turn the keys off with `playerView.keyboardShortcutsEnabled = false`.

## Zoom

Pinch scales the picture from 1× to 5×. The frame clips the image, so the scaled video does not draw over the rest of the screen. Above 1× a second finger pans. A badge such as `2x` sits on the video; tapping it resets to 1×. The same controls live in the settings row **Scale**. See [Settings menu](settings-menu.md).

## First frame of chrome

When playback starts, the center button, title, gradients, and seek bar are shown together. They hide on the usual timer. While a finger is on the seek bar, the center play button is hidden and comes back when the finger lifts.

## Live

Live videos replace the duration clock with the live indicator. See [Live](live.md).

## Empty chrome

Pass `nil` overlay, control panel, and shadow when the host draws its own controls (Shorts):

```swift
playerView.setLayout(with: .builder()
    .setGravity(.resizeAspect)
    .setOverlay(nil)
    .setControlPanel(nil)
    .setShadowOverlay(nil)
    .build())
```
