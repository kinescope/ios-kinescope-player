//
//  KinescopeEventsCenter.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 22.04.2021.
//

import Foundation

/// Enumeration of sdk events
public enum KinescopeEvent: String {
    case playback
    case play
    case pause
    case end
    case replay
    case buffering
    case seek
    case rate
    case view
    case enterfullscreen
    case exitfullscreen
    case qualitychanged
    case autoqualitychanged

    var notificationName: Notification.Name {
        return Notification.Name("io.kinescope." + rawValue)
    }
}

/// Interface for events center
public protocol KinescopeEventsCenter: AnyObject {

    /// Add observer for event
    /// - Parameters:
    ///   - observer: Observer object
    ///   - selector: Method selector
    ///   - event: Kinescope event
    func addObserver(_ observer: Any, selector: Selector, event: KinescopeEvent)

    /// Removes observer for event
    /// - Parameters:
    ///   - observer: Observer object
    ///   - event: Kinescope event
    func removeObserver(_ observer: Any, event: KinescopeEvent)

    /// Removes observer for all events
    /// - Parameters:
    ///   - observer: Observer object
    func removeObserver(_ observer: Any)


    /// Posts event
    /// - Parameters:
    ///   - event: Kinescope event
    func post(event: KinescopeEvent, userInfo: [AnyHashable : Any]?)
}
