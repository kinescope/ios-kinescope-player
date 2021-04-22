//
//  LocalEventsCenter.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 22.04.2021.
//

import Foundation

class LocalEventsCenter: KinescopeEventsCenter {

    // MARK: - Private Properties

    private let nc = NotificationCenter.default
    private let analitycsService: Void

    // MARK: - Init

    init(analitycsService: Void) {
        self.analitycsService = analitycsService
    }

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

    // MARK: - Internal API

    func post(event: KinescopeEvent, userInfo: [AnyHashable : Any]? = nil) {
        nc.post(name: event.notificationName, object: nil, userInfo: userInfo)
        handleAnalitycs(event: event, userInfo: userInfo)
    }


}

// MARK: - Private

private extension LocalEventsCenter {

    func handleAnalitycs(event: KinescopeEvent, userInfo: [AnyHashable : Any]? = nil) {

    }

}
