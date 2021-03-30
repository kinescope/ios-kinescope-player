//
//  KinescopeActivityIndicator.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 30.03.2021.
//

/// Abstract protocol for activity indicator used to indicate process of video downloading
public protocol KinescopeActivityIndicator {
    func showVideoProgress(isLoading: Bool)
}
