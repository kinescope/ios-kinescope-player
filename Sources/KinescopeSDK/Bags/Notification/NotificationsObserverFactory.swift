//
//  NotificationsObserverFactory.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 26.02.2024.
//

import Foundation

/// Protocol for initialisation of subscriptions to notifications
protocol NotificationsObserverFactory: Factory {
    func provide() -> Selector?
}

/// Structure to store the notification name and the object to observe
struct SelectorBasedObserverFactory: NotificationsObserverFactory {

    private let selector: Selector

    let object: Any?

    init(selector: Selector,
         object: Any? = nil) {
        self.selector = selector
        self.object = object
    }

    func provide() -> Selector? {
        selector
    }
}
