//
//  GenericBag.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 26.02.2024.
//

import Foundation

class GenericBag<T: Hashable, F: Factory>: Bag {

    typealias Key = T
    typealias ObserverFactory = F

    private(set) var observers: [T: (factory: ObserverFactory, observer: ObserverFactory.T?)] = [:]

    func addObserver(for key: T, using factory: F) {
        let observer = factory.provide()
        observers[key] = (factory, observer)
    }

    func removeObserver(for key: T) {
        observers.removeValue(forKey: key)
    }

    func removeAll() {
        observers.removeAll()
    }
}
