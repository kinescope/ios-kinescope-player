//
//  KinescopeActivityIndicator.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 30.03.2021.
//

import UIKit

/// Alias for view implementing `KinescopeActivityIndicating`
public typealias KinescopeActivityIndicator = UIView & KinescopeActivityIndicating

/// Abstraction for activity indicator used to indicate process of video downloading
public protocol KinescopeActivityIndicating {

    /// Comand to display video loading state
    /// - parameter isLoading: If value is `true` than startAnimating view like `UIActivityIndicator`.
    /// Otherwise, stopAnimating and hide indicator.
    func showVideoProgress(isLoading: Bool)
}
