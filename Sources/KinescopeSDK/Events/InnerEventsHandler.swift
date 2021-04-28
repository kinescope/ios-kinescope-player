//
//  InnerEventsHandler.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 27.04.2021.
//

import Foundation

protocol InnerEventsHandler {
    func playback(sec: TimeInterval)
    func play()
    func pause()
    func end()
    func replay()
    func buffer(sec: TimeInterval)
    func seek()
    func rate(_ rate: Float)
    func view()
    func enterfullscreen()
    func exitfullscreen()
    func qualitychanged(_ quality: String)
    func autoqualitychanged(_ quality: String)
}
