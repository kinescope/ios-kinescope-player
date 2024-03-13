//
//  NotificationsBag.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 26.02.2024.
//

import Foundation

final class NotificationsBag: GenericBag<NotificationSubKey, SelectorBasedObserverFactory> {
    
    private let observer: Any

    init(observer: Any) {
        self.observer = observer
    }

    override func addObserver(for key: NotificationSubKey, using factory: SelectorBasedObserverFactory) {
        guard let selector = factory.provide() else {
            return
        }
        NotificationCenter.default.addObserver(observer,
                                               selector: selector,
                                               name: key.notificationName,
                                               object: factory.object)
    }

    override func removeAll() {
        super.removeAll()
        NotificationCenter.default.removeObserver(observer)
    }

}
