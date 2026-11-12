# Offline downloads

Downloads go through `Kinescope.shared.videoDownloader` (`KinescopeVideoDownloadable`). The transport is `AVAssetDownloadURLSession`: AVFoundation writes an HLS package (`.movpkg`) and reports progress as loaded time, not bytes.

FairPlay is the DRM used for offline playback on iOS. A clear video downloads with no license round trip. A commercial-DRM video also stores a persistent content key, and later playback uses that file instead of the license server.

The example keeps download out of the player chrome. Saved videos is a dark list with an empty state and an add button. Add opens a video id field, the dashboard catalog, and a quality sheet.

## Basic flow

1. Load metadata: `Kinescope.shared.inspector.video(id:onSuccess:onError:)`.
2. List heights with `KinescopeOffline.qualities(for:)` and pick one. A download with `minimumHeight: nil` lets AVFoundation choose the rendition.
3. Start: `videoDownloader.enqueueDownload(videoId:url:video:minimumHeight:)`. Pass the `KinescopeVideo` so a DRM download can keep an offline key and so the title, description, and poster URL are saved.
4. Subscribe with `KinescopeVideoDownloadableDelegate`. Remove the delegate when the screen goes away.
5. Play with `KinescopePlayerConfig(videoId:localPlaybackURL:)`. The URL comes from `getLocation(by:)`.

```swift
Kinescope.shared.inspector.video(id: videoId, onSuccess: { video in
    KinescopeOffline.qualities(for: video) { qualities in
        guard let url = URL(string: video.hlsLink),
              let height = qualities.first?.height else { return }
        Kinescope.shared.videoDownloader.enqueueDownload(videoId: video.id,
                                                        url: url,
                                                        video: video,
                                                        minimumHeight: height)
    }
}, onError: { _ in })
```

`VideoDownloader` calls `restore()` when the SDK is configured. A host that builds its own downloader should call `restore()` once after launch.

## Quality selection

`KinescopeOffline.qualities(for:)` reads `qualityMap` when the video has one. Otherwise it fetches the HLS master playlist and collects `RESOLUTION` heights. Labels are the asset name, or `"720p"` when the name is empty. Heights are unique and sorted high to low.

`minimumHeight` is passed to `AVAssetDownloadTask` as `AVAssetDownloadTaskMinimumRequiredPresentationSizeKey` (16:9 width derived from the height). That asks AVFoundation for one rendition. It is not a Media3 stream-key filter: the system still decides which variant meets the size.

## What is stored

| Piece | Where | When |
| --- | --- | --- |
| HLS package | Bookmark of the `.movpkg`, saved in `UserDefaults` when the session completes | `didCompleteWithError` is `nil` and the file is on disk |
| Video id ↔ manifest URL | `IDsUDStorage`, suffix for the asset session | From enqueue until finish or error |
| Metadata JSON | `Application Support/KinescopeOfflineVideos/<id>.json` | `enqueueDownload`, when a `KinescopeVideo` is passed |
| Poster image | Same folder, `<id>.poster` | Started with the download; the file appears when the image request finishes |
| FairPlay key | `Application Support/KinescopeFairPlay/<id>` (no extension) | DRM download, after the license server returns a CKC |

The poster request is fire-and-forget. A video downloaded before that copy existed has metadata and no image. Delete it and download again to get the poster.

`didFinishDownloadingTo` only remembers the package location. The download is published from `didCompleteWithError` when that error is `nil`, the package is still on disk, and — for a video whose saved metadata has `drm` — the persistent key is on disk. If the license request is still running when the session completes, publication waits for that request. A session error, a missing package, or a failed key request is `videoDownloadError`, and the package is deleted.

The stored location is a bookmark. `getLocation(by:)` resolves it, including after the system moves the package inside the container. Records written before bookmarks still resolve as plain paths. `delete(videoId:)` removes the record, the JSON, the poster, and the key when the file is already missing, so a dead row does not stay in the list. A real failure to delete an existing file returns `false` and leaves the record in place.

`VideoDownloader` calls `restore()` when it is created. That recreates the FairPlay content-key session for every unfinished DRM download **before** the background `AVAssetDownloadURLSession` is reconnected, then binds each task's asset and resumes it. A clear download has no key session.

## Progress and library

```swift
let ids = Kinescope.shared.videoDownloader.downloadedList()
let file = Kinescope.shared.videoDownloader.getLocation(by: videoId)
Kinescope.shared.videoDownloader.pauseDownload(videoId: videoId)
Kinescope.shared.videoDownloader.resumeDownload(videoId: videoId)
Kinescope.shared.videoDownloader.dequeueDownload(videoId: videoId) // cancel an active task
let removed = Kinescope.shared.videoDownloader.delete(videoId: videoId)
Kinescope.shared.videoDownloader.clear()
```

`videoDownloadProgress` reports `0...100` (loaded duration / expected duration). `videoDownloadError` uses `KinescopeDownloadError`. `videoDownloadComplete` fires after the package location is saved.

`isDownloaded` is true when the id is in `downloadedList()`. That list is the path store, not a check that the file still exists.

## Play a download

```swift
let player = KinescopeVideoPlayer(config: .init(videoId: videoId,
                                                localPlaybackURL: file))
player.attach(view: playerView)
player.play()
```

This is the same `KinescopeVideoPlayer` and `KinescopePlayerView` as online playback. `localPlaybackURL` skips the metadata request and plays `.downloaded(url:)`. Title and description come from the JSON copy. The poster and the lock-screen artwork use `<id>.poster` when that file exists, otherwise the remote poster URL.

`videoId` is still required. It selects the JSON, the poster, and the FairPlay key.

See [Local playback](local-playback.md).

## Download a Short

`KinescopeShortsViewController` does not download. Take the video `id` from the same dashboard list the feed uses (`KinescopeDashboard.videos` with that `projectId` and `folderId`) and run the basic flow. Playback of the saved file is a normal player with `localPlaybackURL`.

```swift
func downloadShort(id: String) {
    Kinescope.shared.inspector.video(id: id, onSuccess: { video in
        KinescopeOffline.qualities(for: video) { qualities in
            guard let url = URL(string: video.hlsLink) else { return }
            Kinescope.shared.videoDownloader.enqueueDownload(videoId: video.id,
                                                            url: url,
                                                            video: video,
                                                            minimumHeight: qualities.first?.height)
        }
    }, onError: { _ in })
}

func playDownloadedShort(id: String, in playerView: KinescopePlayerView) {
    guard let file = Kinescope.shared.videoDownloader.getLocation(by: id) else { return }
    let player = KinescopeVideoPlayer(config: .init(videoId: id, localPlaybackURL: file))
    player.attach(view: playerView)
    player.play()
}
```

`downloadShort` starts the transfer. `playDownloadedShort` runs after `videoDownloadComplete` for that id, or when `getLocation(by:)` already returns a file.

## FairPlay

Only a commercial-DRM video exposes license URLs. For `"free"` and `"aes-128"` the public JSON has `"drm": {}` even when the media is encrypted. Offline FairPlay needs:

```json
"drm": {
  "fairplay": {
    "licenseUrl": "https://license.kinescope.io/v2/vod/{entity}/acquire/fairplay",
    "certificateUrl": "https://license.kinescope.io/v2/vod/{entity}/certificate/fairplay"
  }
}
```

Those URLs come from `Kinescope.shared.inspector`. The download path passes `persistable: true` into `DataProtectionKeySessionHandler` and binds that session to the asset **before** `makeAssetDownloadTask`. Reversing the order can surface `AVErrorOperationNotAllowed` (`-11862`).

```text
AVFoundation -> SDK: content key request
SDK: respondByRequestingPersistableContentKeyRequest
SDK -> certificate URL: DER certificate
SDK: SPC via makeStreamingContentKeyRequestData
SDK -> license URL: {"spc":"<base64>"}
license server -> SDK: {"ckc":"<base64>"}
SDK: persistableContentKey(fromKeyVendorResponse:) -> one file per video id

offline:
AVFoundation -> SDK: content key request
SDK -> AVFoundation: the file, no license server
```

Playback of a downloaded DRM file calls `makeDownloadedItem`. The saved key is applied only when `hasOfflineKey` is true. A clear download is left unbound.

FairPlay cannot be verified in the Simulator. Use a device and a commercial-DRM video. Airplane mode is the check that playback no longer calls the license server.

## What still needs the network

| Piece | Offline |
| --- | --- |
| Video package | Local `.movpkg` |
| Title, description, chapters from the saved JSON | Local |
| Poster and Now Playing artwork | Local, after the poster file has been written |
| Subtitles | Remote URL on each selection. The cue file is not saved |
| Quality change | Selects `.exact` or `.auto(hlsLink)` and leaves the local file |
| Playlist | Whatever the host passed to `setPlaylist`. The SDK does not save it with the download |
| Attachments | Separate downloader, not part of this pipeline |

`FeatureToggle.assetDownloaderEnabled` is `false`. The older per-asset `AssetDownloader` is not the path the example uses.
