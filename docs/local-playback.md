# Local playback

`KinescopePlayerConfig.localPlaybackURL` plays a file instead of requesting HLS. The player, the view, and the chrome are the same objects as online playback.

```swift
let player = KinescopeVideoPlayer(config: .init(videoId: videoId,
                                                localPlaybackURL: fileURL))
player.attach(view: playerView)
player.play()
```

Use the URL from `videoDownloader.getLocation(by:)`. `videoId` is still required: it selects the saved metadata, the poster file, PiP identity, analytics, and the FairPlay key.

## Downloaded Kinescope video

When `localPlaybackURL` is set and `Application Support/KinescopeOfflineVideos/<id>.json` exists, `load()` does not call the network:

- title and description come from that JSON;
- the poster is `Application Support/KinescopeOfflineVideos/<id>.poster` when the file exists, otherwise the poster URL inside the JSON (that URL fails offline);
- Now Playing artwork uses the same poster source;
- a saved FairPlay key is attached in `makeDownloadedItem` only if the key file exists. A clear download is not bound to a key session.

The JSON is written at `enqueueDownload` when the caller passes `video:`. The poster file is written by a separate image request started at the same time. See [Offline downloads](offline-downloads.md).

## What does not switch to the file

- Subtitles are fetched from the subtitle URL when the viewer turns them on.
- A quality pick leaves the local file and selects a network rendition (`.exact` or `.auto`).
- The playlist is only what the host set with `setPlaylist`. It is not stored next to the download.

A single local file has one rendition. The height was chosen with `minimumHeight` at download time.
