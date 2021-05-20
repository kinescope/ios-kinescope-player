//
//  InnerEventsProtoHandler.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 27.04.2021.
//

import UIKit

enum InnerProtoEvent: String {
    case playback
    case play
    case pause
    case end
    case replay
    case buffering
    case seek
    case rate
    case view
    case enterfullscreen
    case exitfullscreen
    case qualitychanged
    case autoqualitychanged
}

class InnerEventsProtoHandler: InnerEventsHandler {

    // MARK: - Properties

    private var service: AnalyticsService
    private var video = Analytics_Video()
    private var player = Analytics_Player()
    private var device = Analytics_Device()
    private var session = Analytics_Session()
    private var playback = Analytics_Playback()

    // MARK: - Init

    init(service: AnalyticsService) {
        self.service = service
    }

    // MARK: - Internal Methods

    // Video

    func setupVideo(_ video: KinescopeVideo) {
        self.video.duration = UInt32(video.duration)
        self.video.source = video.hlsLink
    }

    // Player

    func setupPlayer() {
        self.player.type = "iOS SDK"
        self.player.version = Bundle(for: Self.self).infoDictionary?["CFBundleVersion"] as? String ?? ""
    }

    // Device

    func setupDevice() {
        self.device.os = "iOS"
        self.device.osversion = UIDevice.current.systemVersion
        self.device.screenWidth = UInt32(UIScreen.main.bounds.width)
        self.device.screenHeight = UInt32(UIScreen.main.bounds.height)
    }

    // Session

    func setSessionId() {
        let uuid = UUID()
        let data = withUnsafePointer(to: uuid) {
            Data(bytes: $0, count: MemoryLayout.size(ofValue: uuid))
        }
        self.session.id = data
    }

    func setSession(viewID uuid: UUID) {
        let data = withUnsafePointer(to: uuid) {
            Data(bytes: $0, count: MemoryLayout.size(ofValue: uuid))
        }
        self.session.viewID = data
    }

    func setSession(type: Analytics_SessionType) {
        self.session.type = type
    }

    func setSession(watchedDuration duration: Int) {
        self.session.watchedDuration = UInt32(duration)
    }

    func setSession(externalId id: String) {
        self.session.externalID = id
    }

    // Playback

    func setPlayback(rate: Float) {
        self.playback.rate = rate
    }

    func setPlayback(volume: Int) {
        self.playback.volume = Int32(volume)
    }

    func setPlayback(quality: String) {
        self.playback.quality = quality
    }

    func setPlayback(isMuted: Bool) {
        self.playback.isMuted = isMuted
    }

    func setPlayback(isFullscreen: Bool) {
        self.playback.isFullscreen = isFullscreen
    }

    func setPlayback(previewPosition position: Int) {
        self.playback.previewPosition = UInt32(position)
    }

    func setPlayback(currentPosition position: Int) {
        self.playback.currentPosition = UInt32(position)
    }

    // MARK: - InnerEventsHandler

    func playback(sec: TimeInterval) {
        send(event: .playback, value: 0)
    }

    func play() {
        send(event: .play, value: 0)
    }

    func pause() {
        send(event: .pause, value: 0)
    }

    func end() {
        send(event: .end, value: 0)
    }

    func replay() {
        send(event: .replay, value: 0)
    }

    func buffering(sec: TimeInterval) {
        send(event: .buffering, value: Float(sec))
    }

    func seek() {
        send(event: .seek, value: 0)
    }

    func rate(_ rate: Float) {
        send(event: .rate, value: rate)
    }

    func view() {
        send(event: .view, value: 0)
    }

    func enterfullscreen() {
        send(event: .enterfullscreen, value: 0)
    }

    func exitfullscreen() {
        send(event: .exitfullscreen, value: 0)
    }

    func qualitychanged() {
        send(event: .qualitychanged, value: 0)
    }

    func autoqualitychanged() {
        send(event: .autoqualitychanged, value: 0)
    }
    
}

// MARK: - Private

private extension InnerEventsProtoHandler {

    func send(event: InnerProtoEvent, value: Float) {
        service.send(event: build(event: event, value: value)) {
            switch $0 {
            case .failure(let error):
                Kinescope.shared.logger?.log(message: "Inner event (\(event) registration failed with error: \(error)", level: KinescopeLoggerLevel.analytics)
            case .success(_):
                Kinescope.shared.logger?.log(message: "Inner event (\(event) was registered", level: KinescopeLoggerLevel.analytics)
            }
        }
    }

    func build(event: InnerProtoEvent, value: Float) -> Analytics_Native {
        return Analytics_Native.with {
            $0.event = event.rawValue
            $0.value = value
            $0.video = video
            $0.player = player
            $0.device = device
            $0.session = session
            $0.playback = playback
            $0.eventTime = .init()
            return
        }
    }

}
