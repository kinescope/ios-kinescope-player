//
//  Repeater.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 04.03.2024.
//

import Foundation

enum RepeaterState {
    case inProgress
    case limitReached
}

struct TitledAction {
    let title: String
    let action: () -> Void
}

protocol ActionOwner {
    var action: TitledAction? { get set }
}

protocol Repeater: AnyObject {
    func start() -> RepeaterState
    func reset()
}

final class DefaultRepeater: Repeater, ActionOwner {

    // MARK: - Properties
    
    private let executionQueue: DispatchQueue
    private let attemptsLimit: UInt
    private let intervalSeconds: TimeInterval

    private var workItem: DispatchWorkItem?
    private var attempts: UInt = 0

    var action: TitledAction?

    // MARK: - Calculated properties

    private var canRepeat: Bool {
        return attempts < attemptsLimit
    }

    // MARK: - Init

    init(executionQueue: DispatchQueue,
         attemptsLimit: UInt,
         intervalSeconds: TimeInterval) {
        self.executionQueue = executionQueue
        self.attemptsLimit = attemptsLimit
        self.intervalSeconds = intervalSeconds
    }

    // MARK: - Repeater

    func start() -> RepeaterState {
        if canRepeat {
            workItem?.cancel()
            workItem = DispatchWorkItem { [weak self] in
                guard let self, let action else {
                    return
                }
                attempts += 1
                Kinescope.shared.logger?.log(message: "🔄 attempt \(attempts) trying to repeat \(action.title)",
                                             level: KinescopeLoggerLevel.repeater)
                action.action()
            }
            executionQueue.asyncAfter(deadline: .now() + intervalSeconds, execute: workItem!)
            return .inProgress
        } else {
            return .limitReached
        }
    }

    func reset() {
        attempts = 0
    }

}

// MARK: - Property wrapper

@propertyWrapper
struct Repeating {

    var wrappedValue: TitledAction? {
        get { repeater.action }
        set { repeater.action = newValue }
    }

    var repeater: Repeater & ActionOwner

    var projectedValue: Repeater {
        return repeater
    }

    init(executionQueue: DispatchQueue,
         attemptsLimit: UInt,
         intervalSeconds: TimeInterval) {
        self.repeater = DefaultRepeater(executionQueue: executionQueue,
                                        attemptsLimit: attemptsLimit,
                                        intervalSeconds: intervalSeconds)
    }

}
