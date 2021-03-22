//
//  KinescopeWrapper.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 22.03.2021.
//

// Wrap Base instance for easy access
public struct KinescopeWrapper<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}
