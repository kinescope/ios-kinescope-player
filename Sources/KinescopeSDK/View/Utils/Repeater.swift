//
//  Repeater.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 04.03.2024.
//

import Foundation

/// Parameters for repeating of failed requests
public struct RepeatingMode {

    let attempts: UInt
    let interval: DispatchTimeInterval

    /// Default repeating mode with 10 attempts and 5 seconds interval
    public static let `default` = RepeatingMode(attempts: 10, interval: .seconds(5))

    /// Repeating mode with infinite attempts and custom interval
    public static func infinite(interval: DispatchTimeInterval) -> RepeatingMode {
        return RepeatingMode(attempts: .max, interval: interval)
    }

    /// - Parameters:
    ///  - attempts: Number of attempts to repeat
    ///  - interval: Time interval between attempts
    public init(attempts: UInt, interval: DispatchTimeInterval) {
        self.attempts = attempts
        self.interval = interval
    }
}

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
    private let mode: RepeatingMode

    private var workItem: DispatchWorkItem?
    private var attempts: UInt = 0

    var action: TitledAction?

    // MARK: - Calculated properties

    private var canRepeat: Bool {
        return attempts < mode.attempts
    }

    // MARK: - Init

    init(executionQueue: DispatchQueue,
         mode: RepeatingMode) {
        self.executionQueue = executionQueue
        self.mode = mode
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
            executionQueue.asyncAfter(deadline: .now() + mode.interval, execute: workItem!)
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
         mode: RepeatingMode) {
        self.repeater = DefaultRepeater(executionQueue: executionQueue,
                                        mode: mode)
    }

}
