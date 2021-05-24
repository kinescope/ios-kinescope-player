# KinescopeVideosRequest

Request info with sort order and requested page chunk

``` swift
public struct KinescopeVideosRequest: Encodable 
```

## Inheritance

`Encodable`

## Initializers

### `init(page:perPage:order:)`

``` swift
public init(page: Int, perPage: Int = 5, order: String? = nil) 
```

## Properties

### `page`

Requested page index

``` swift
public var page: Int
```

Starts from `1`

### `perPage`

Count of videos per page

``` swift
public let perPage: Int
```

By default equal to 5

### `order`

Sort order of videos.

``` swift
public let order: String?
```

For example: created\_at.desc,title.asc

## Methods

### `next()`

Increase page by one

``` swift
public mutating func next() -> KinescopeVideosRequest 
```
