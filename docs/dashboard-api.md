# Dashboard API

`KinescopeDashboard` calls `GET https://api.kinescope.io/v1/videos/` with `Authorization: Bearer <apiKey>`.

```swift
KinescopeDashboard.videos(page: 1, perPage: 100) { result in
    switch result {
    case .success(let videos):
        // KinescopeLibraryVideo: id, title, posterURL, duration, summary
        break
    case .failure:
        break
    }
}
```

Set the key with `KinescopeConfig(apiKey:)`. Without it the callback fails with `KinescopeDashboardError.missingAPIKey`.

A page is cached in memory under `page`, `perPage`, `projectId`, and `folderId`. A later call with the same key returns on the main queue without another request. Calls that overlap one request share that request. A different project or folder is a different list. The example home screen prefetches `KinescopeDemoConfig`, and Playlist test and Shorts call that same key, so the push does not wait on the network.

Player templates are not wrapped by `KinescopeDashboard`. The Custom Player example calls:

- `GET /v1/players`
- `POST /v1/players`
- `PUT /v1/players/{id}`
- `DELETE /v1/players/{id}`

The settings object is the player template format. See [Player options](player-options.md).
