//
//  KinescopeInspectable.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//

/// Protocol managing inspectations of dashboard content like videos, projects etc
public protocol KinescopeInspectable: AnyObject {

    /// Entry for `GET` Video task
    ///
    /// - parameter id: id of video to inspect
    /// - parameter onSuccess: callback on success. Returns `KinescopeVideo` object aplicable for player.
    /// - parameter onError: callback on error.
    func video(id: String,
               onSuccess: @escaping (KinescopeVideo) -> Void,
               onError: @escaping (KinescopeInspectError) -> Void)

    /// Entry for `GET` Video task of DRM-protected video with authorization
    ///
    /// - parameter id: id of video to inspect
    /// - parameter drmAuthToken: token sent as `drmauthtoken` query parameter
    /// - parameter onSuccess: callback on success. Returns `KinescopeVideo` object aplicable for player.
    /// - parameter onError: callback on error.
    func video(id: String,
               drmAuthToken: String?,
               onSuccess: @escaping (KinescopeVideo) -> Void,
               onError: @escaping (KinescopeInspectError) -> Void)

}

public extension KinescopeInspectable {

    func video(id: String,
               drmAuthToken: String?,
               onSuccess: @escaping (KinescopeVideo) -> Void,
               onError: @escaping (KinescopeInspectError) -> Void) {
        video(id: id, onSuccess: onSuccess, onError: onError)
    }

}
