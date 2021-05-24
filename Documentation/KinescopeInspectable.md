# KinescopeInspectable

Protocol managing inspectations of dashboard content like videos, projects etc

``` swift
public protocol KinescopeInspectable: AnyObject 
```

## Inheritance

`AnyObject`

## Requirements

### list(request:​onSuccess:​onError:​)

Entry for `GET` Video list

``` swift
func list(request: KinescopeVideosRequest,
              onSuccess: @escaping (([KinescopeVideo], KinescopeMetaData)) -> Void,
              onError: @escaping (KinescopeInspectError) -> Void)
```

#### Parameters

  - request: request info with sort order and requested page chunk
  - onSuccess: callback on success. Returns list of videos available with meta info about totalCount of videos
  - onError: callback on error.

### video(id:​onSuccess:​onError:​)

Entry for `GET` Video

``` swift
func video(id: String,
               onSuccess: @escaping (KinescopeVideo) -> Void,
               onError: @escaping (KinescopeInspectError) -> Void)
```

#### Parameters

  - id: video id
  - onSuccess: callback on success. Returns video model
  - onError: callback on error.

### fetchPlaylist(link:​completion:​)

Entry for video playlists fetching

``` swift
func fetchPlaylist(link: String, completion: @escaping (M3U8Manager.Result<MasterPlaylist>) -> (Void))
```
