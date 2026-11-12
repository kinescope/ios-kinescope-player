# Subtitles

Subtitles are a control-bar button and a settings row.

## On the video

Cues render in `SubtitleOverlayView`. Style (font, color, size percent, background color and opacity) is edited from the subtitle look screens in the same menu. Reset restores the default style.

## Search

Search opens over the full player, not a small card. The list stays open after a line is chosen. The chosen line stays highlighted and the player seeks to that cue. The clock on each row is the cue start.

## Turning them off

```swift
player.disableOptions([.subtitles])
```

The settings row is still built from the video's subtitle list. Hiding the button is the switch for the control bar.
