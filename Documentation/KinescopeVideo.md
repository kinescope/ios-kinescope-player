# KinescopeVideo

Video model

``` swift
public struct KinescopeVideo: Codable 
```

## Inheritance

`Codable`

## Properties

### `id`

``` swift
public let id: String
```

### `projectId`

``` swift
public let projectId: String
```

### `version`

``` swift
public let version: Int
```

### `title`

``` swift
public let title: String
```

### `description`

``` swift
public let description: String
```

### `status`

``` swift
public let status: String
```

### `progress`

``` swift
public let progress: Int
```

### `duration`

``` swift
public let duration: Double
```

### `assets`

``` swift
public let assets: [KinescopeVideoAsset]
```

### `chapters`

``` swift
public let chapters: KinescopeVideoChapter
```

### `poster`

``` swift
public let poster: KinescopeVideoPoster?
```

### `additionalMaterials`

``` swift
public let additionalMaterials: [KinescopeVideoAdditionalMaterial]
```

### `subtitles`

``` swift
public let subtitles: [KinescopeVideoSubtitle]
```

### `hlsLink`

``` swift
public let hlsLink: String
```

### `manifest`

``` swift
public var manifest: MasterPlaylist? = nil
```
