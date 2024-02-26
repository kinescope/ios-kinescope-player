//
//  KVOBag.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 26.02.2024.
//

import Foundation

final class KVOBag: GenericBag<KVOSubKey, AnyKVOObserverFactory> {
    
    override func removeObserver(for key: KVOSubKey) {
        observers[key]?.observer?.invalidate()
        super.removeObserver(for: key)
    }

    override func removeAll() {
        observers.forEach { $0.value.observer?.invalidate() }
        super.removeAll()
    }

}
