# KinescopeInspectError

Enumeration of possible negative cases while downloading content

``` swift
public enum KinescopeInspectError: Error 
```

## Inheritance

`Error`

## Enumeration Cases

### `network`

Network problems

``` swift
case network
```

### `notFound`

Video not found

``` swift
case notFound
```

### `denied`

Denied by dashboard or by system when saving in local storage

``` swift
case denied
```

### `unknown`

Unexpected error

``` swift
case unknown(Error)
```
