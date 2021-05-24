//
//  LocalEventsCenter.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 22.04.2021.
//

import Foundation

/// Base KinescopeEventsCenter implementation. Uses NotificationCenter
class LocalEventsCenter: KinescopeEventsCenter {

    // MARK: - Private Properties

    private let nc = NotificationCenter.default

    // MARK: - KinescopeEventsCenter

    func addObserver(_ observer: Any, selector: Selector, event: KinescopeEvent) {
        nc.addObserver(observer, selector: selector, name: event.notificationName, object: nil)
    }

    func removeObserver(_ observer: Any, event: KinescopeEvent) {
        nc.removeObserver(observer, name: event.notificationName, object: nil)
    }

    func removeObserver(_ observer: Any) {
        nc.removeObserver(observer)
    }

    func post(event: KinescopeEvent, userInfo: [AnyHashable : Any]? = nil) {
        nc.post(name: event.notificationName, object: nil, userInfo: userInfo)
    }

}
