# Picture in Picture

The PiP button is `KinescopePlayerOption.pip`. It is shown when the device supports `AVPictureInPictureController`.

Hide it:

```swift
player.disableOptions([.pip])
```

The example keeps a single PiP session. Opening another video closes the previous PiP for that id (`PipManager`). Background audio follows the system PiP rules; the player does not start a separate background mode beyond what PiP already requires.

The Custom Player switch "Picture in picture" writes `picture_in_picture` on the player template and hides the button when it is off.
