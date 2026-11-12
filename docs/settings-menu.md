# Settings menu

The gear fades the settings card in above the control bar. Each next screen slides in from the right, the previous screen slides out to the left, and the card height eases to the new list. Back runs the same motion in reverse. Rows:

- Playback speed, unless `playerView.showsPlaybackRateSetting` is `false`
- Subtitles, including search
- Audio, when the stream has more than one track
- Quality
- Scale, with the current percent (`100%` and up)

Choosing a row pushes the next list. The current value is a checkmark. Quality `Auto` clears the peak bitrate and the gear badge follows the rendition that is actually playing. That badge is refreshed about once a second, and only while the control panel is on screen: reading the player access log is a synchronous call to the media server. A named rendition (`720p` and similar) sets `preferredPeakBitRate` for that rung. `player.selectQuality(named:)` accepts `auto`, `360`, `480`, `720`, `1080`, `720p`, and `audio`.

Speed values come from `KinescopePlayingRate`.

The scale row's nested actions are **− 3%**, **+ 3%**, and **100%**. Pinch on the video goes from 1× to 5× and pans inside the player frame; the badge (for example `2x`) resets the scale. The percent on the disclosure row updates immediately.

The menu slides over the video. A horizontal scrub does not trigger the navigation back gesture: the player claims that pan, and the example disables the interactive pop while the video screen is visible.
