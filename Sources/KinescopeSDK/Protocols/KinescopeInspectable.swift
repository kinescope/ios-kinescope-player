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

}
