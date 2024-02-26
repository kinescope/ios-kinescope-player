//
//  Factory.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 26.02.2024.
//

import Foundation

protocol Factory {
    associatedtype T
    func provide() -> T
}
