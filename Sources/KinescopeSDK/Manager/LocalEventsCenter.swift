//
//  LocalEventsCenter.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 22.04.2021.
//

import Foundation

class LocalEventsCenter: KinescopeEventsCenter {

    // MARK: - Private Properties

    private let nc = NotificationCenter.default
    private let innerEventsHandler: InnerEventsHandler

    // MARK: - Init

    init(innerEventsHandler: InnerEventsHandler) {
        self.innerEventsHandler = innerEventsHandler
    }

    // MARK: - KinescopeEventsCenter

    func addObserver(_ observer: Any, selector: Selector, event: KinescopeEvent) {
        nc.addObserver(observer, selector: selector, name: event.notificationName, object: nil)
    }

    func removeObserver(_ observer: Any, event: KinescopeEvent) {
        nc.removeObserver(observer, name: event.notificationName, object: nil)
    }

    func removeObserver(_ observer: Any) {
        nc.removeObserver(observer)
    }

    // MARK: - Internal API

    func post(event: KinescopeEvent, userInfo: [AnyHashable : Any]? = nil) {
        nc.post(name: event.notificationName, object: nil, userInfo: userInfo)
        handleAnalitycs(event: event, userInfo: userInfo)
    }


}

// MARK: - Private

private extension LocalEventsCenter {

    func handleAnalitycs(event: KinescopeEvent, userInfo: [AnyHashable : Any]? = nil) {
        switch event {
        case .playback:
            guard let sec = userInfo?["sec"] as? TimeInterval else {
                return
            }
            innerEventsHandler.playback(sec: sec)
        case .play:
            innerEventsHandler.play()
        case .pause:
            innerEventsHandler.pause()
        case .end:
            innerEventsHandler.end()
        case .replay:
            innerEventsHandler.replay()
        case .buffering:
            guard let sec = userInfo?["sec"] as? TimeInterval else {
                return
            }
            innerEventsHandler.buffer(sec: sec)
        case .seek:
            innerEventsHandler.seek()
        case .rate:
            guard let rate = userInfo?["rate"] as? Float else {
                return
            }
            innerEventsHandler.rate(rate)
        case .view:
            innerEventsHandler.view()
        case .enterfullscreen:
            innerEventsHandler.enterfullscreen()
        case .exitfullscreen:
            innerEventsHandler.exitfullscreen()
        case .qualitychanged:
            guard let quality = userInfo?["quality"] as? String else {
                return
            }
            innerEventsHandler.qualitychanged(quality)
        case .autoqualitychanged:
            guard let quality = userInfo?["quality"] as? String else {
                return
            }
            innerEventsHandler.autoqualitychanged(quality)
        }
    }

}
