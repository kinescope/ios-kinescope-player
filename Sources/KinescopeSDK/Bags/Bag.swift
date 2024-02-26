//
//  Bag.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 26.02.2024.
//

import Foundation

protocol Bag {
    associatedtype Key: Hashable
    associatedtype ObserverFactory: Factory

    func addObserver(for key: Key, using factory: ObserverFactory)
    func removeObserver(for key: Key)
    func removeAll()
}
