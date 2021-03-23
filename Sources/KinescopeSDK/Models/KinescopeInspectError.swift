//
//  KinescopeInspectError.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//

/// Enumeration of possible negative cases while downloading content
public enum KinescopeInspectError: Error {

    /// Network problems
    case network
    /// Video not found
    case notFound
    /// Denied by dashboard or by system when saving in local storage
    case denied
    /// Unexpected error
    case unknown(Error)

}
