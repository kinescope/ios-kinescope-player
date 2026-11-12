# Demo app

Open `Example/KinescopeExample.xcworkspace`. The scheme is `KinescopeExample`. The home screen has these buttons:

- Playlist test — player on top, light list of the same project the home screen loads, copy link, "N of M videos". Nothing plays until a row is tapped.
- Subtitles test
- Chapters test — chapter rows show the start time
- DRM viewing
- Custom player — template save / use / update / delete, and the playback switches
- Live test
- Shorts — opens `KinescopeShortsViewController` from the SDK with the demo project. Its look is set by `KinescopeShortsUIConfig`; see [customization.md](customization.md#shorts). Vertical paging, a seek bar, and side icons. The poster stays until that page is playing. If the next page was already prepared on its own cell, its first frame shows as the swipe lands. The previous page and the next three are prepared one at a time after the feed has stopped, not during the swipe.
- Saved videos — downloads and the separate download screen

The sample ids and the dashboard token live in the example. They are stand videos. `KinescopeDemoConfig.projectId` limits Playlist test and Shorts to one project, which is the list the home screen already fetched.

While the home screen is idle it builds the Playlist and Shorts view trees, so the first push does not assemble that chrome. Playback still starts only after the screen is on display. The example logger prints DRM events only. Set the scheme environment variable `KINESCOPE_VERBOSE` to `1` to print every player and analytics line. Those lines go through the Xcode debugger on the main thread, so leave them off while judging scroll and first open.

Build for a device:

```bash
cd Example
xcodebuild -workspace KinescopeExample.xcworkspace \
  -scheme KinescopeExample \
  -destination 'generic/platform=iOS' \
  CODE_SIGNING_ALLOWED=NO build
```

Signing for a real iPhone is done in Xcode with your team. Do not regenerate `Example/project.yml`; that resets the bundle id.

New example screens must be added to `KinescopeExample.xcodeproj`. New SDK sources are picked up by the podspec glob; run `pod install` after adding a new Swift file under `Sources/KinescopeSDK`.
