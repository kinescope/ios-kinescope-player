//
//  CallObserver.swift
//  KinescopeSDK
//
//  Created by Никита Гагаринов on 22.04.2021.
//

import CallKit

/// On-device calls states
public enum KinescopeCallState {
    case ended
    case outgoing
    case connected
    case hold
    case none
}

/// Delegate for CallObserver
protocol CallObserverDelegate: AnyObject {
    /// Triggered on state change
    /// - Parameter callState: State
    func callObserver(callState: KinescopeCallState)
}

/// Handles on-device calls
final class CallObserver: NSObject, CXCallObserverDelegate {

    // MARK: - Properties

    weak var delegate: CallObserverDelegate?

    private let callObserver = CXCallObserver()

    // MARK: - Initalization

    override init() {
        super.init()
        callObserver.setDelegate(self, queue: nil)
    }

    // MARK: - CXCallObserverDelegate

    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        var callState: KinescopeCallState = .none

        if call.hasConnected {
            callState = .connected
        }

        if call.hasEnded {
            callState = .ended
        }

        if call.isOnHold {
            callState = .hold
        }

        if call.isOutgoing {
            callState = .outgoing
        }
        
        delegate?.callObserver(callState: callState)
    }

}
