//
//  CallObserver.swift
//  KinescopeSDK
//
//  Created by Никита Гагаринов on 22.04.2021.
//

import CallKit

protocol CallObserverDelegate: class {
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall)
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
        delegate?.callObserver(callObserver, callChanged: call)
    }

}
