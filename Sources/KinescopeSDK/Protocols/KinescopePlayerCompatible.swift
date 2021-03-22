//
//  KinescopePlayerCompatible.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 22.03.2021.
//

// Provide kinescope property to simplify player injection
public protocol KinescopePlayerCompatible: AnyObject { }

extension KinescopePlayerCompatible {
    /// Gets a namespace holder for KinescopePlayer compatible types.
    public var kinescope: KinescopeWrapper<Self> {
        KinescopeWrapper(self)
    }
}
