//
//  KinescopeInspectable.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//

/// Protocol managing inspectations of dashboard content like videos, projects etc
public protocol KinescopeInspectable: class {

    /// Entry for `GET` Video list
    ///
    /// - parameter onSuccess: callback on success. Returns list of videos available
    /// - parameter onError: callback on error.
    func list(onSuccess: @escaping (KinescopeVideoListResponse) -> Void,
              onError: @escaping (KinescopeInspectError) -> Void)

}
