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
    /// - parameter request: request info with sort order and requested page chunk
    /// - parameter onSuccess: callback on success. Returns list of videos available with meta info about totalCount of videos
    /// - parameter onError: callback on error.
    func list(request: KinescopeVideosRequest,
              onSuccess: @escaping (([KinescopeVideo], KinescopeMetaData)) -> Void,
              onError: @escaping (KinescopeInspectError) -> Void)

}
