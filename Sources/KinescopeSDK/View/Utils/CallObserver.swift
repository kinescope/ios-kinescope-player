//
//  CallObserver.swift
//  KinescopeSDK
//
//  Created by Никита Гагаринов on 22.04.2021.
//

import CallKit

public enum KinescopeCallState {
    case ended
    case outgoing
    case connected
    case hold
}

protocol CallObserverDelegate: class {
    func callObserver(callState: KinescopeCallState)
}

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
        var callState: KinescopeCallState = .connected

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
