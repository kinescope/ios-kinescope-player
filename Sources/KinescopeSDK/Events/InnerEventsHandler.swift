//
//  InnerEventsHandler.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 27.04.2021.
//

import Foundation

/// Protocol for inner SDK analytics handler
protocol InnerEventsHandler {
    func playback(sec: Int)
    func play()
    func pause()
    func end()
    func replay()
    func buffering(sec: TimeInterval)
    func seek()
    func rate(_ rate: Float)
    func view()
    func enterfullscreen()
    func exitfullscreen()
    func qualitychanged()
    func autoqualitychanged()
}
