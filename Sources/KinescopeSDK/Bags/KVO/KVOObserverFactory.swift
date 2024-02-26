//
//  KVOObserverFactory.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 26.02.2024.
//

import Foundation

/// Protocol for initialisation of KVOObserver
protocol KVOObserverFactory: Factory {
    func provide() -> NSKeyValueObservation?
}

/// Type erased KVOObserverFactory
struct AnyKVOObserverFactory: KVOObserverFactory {

    private let wrappedFactory: any KVOObserverFactory
    
    init(wrappedFactory: any KVOObserverFactory) {
        self.wrappedFactory = wrappedFactory
    }

    func provide() -> NSKeyValueObservation? {
        wrappedFactory.provide()
    }
}
