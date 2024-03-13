//
//  ApproxTimeInterval.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 11.03.2024.
//

import Foundation

@propertyWrapper
struct ApproxTimeInterval {

    private var step: TimeInterval
    private(set) var accumulatedDiff: TimeInterval = 0

    var wrappedValue: TimeInterval {
        didSet {
            if wrappedValue != oldValue {
                accumulatedDiff = 0
            } else {
                accumulatedDiff += step
            }
        }
    }
    
    var projectedValue: TimeInterval {
        wrappedValue + accumulatedDiff
    }

    /// A property wrapper that accumulates small differences in the wrapped value
    /// It designed to provide approximated values for smooth animation of current position
    ///  - Parameters:
    ///     - wrappedValue: Current value
    ///     - step: Step to accumulate diff. It should be equal to step of periodic timer which update UI.
    /// - **Projected value** is approximated value based on step and accumulated changes.
    init(wrappedValue: TimeInterval, step: TimeInterval) {
        self.step = step
        self.wrappedValue = wrappedValue
    }

}
