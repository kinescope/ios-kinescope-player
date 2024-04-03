//
//  KinescopeAnalyticsDelegate.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 02.04.2024.
//

import Foundation

/// Delegate to listen for analytics sended from ``KinescopeVideoPlayer``
public protocol KinescopeAnalyticsDelegate {
    /// Fired when ``KinescopeVideoPlayer`` is sending any analytics `event`
    ///  - Parameters:
    ///     - event: name of the event
    ///     - data: serialized data in `String` format
    func didSendAnalytics(event: String, with data: String)
}
