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

    var mirror: KinescopeEventsCenter?

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
        self.session.watchedDuration = UInt32(duration) // TODO: what is this?
    }

    func setSession(externalId id: String) {
        self.session.externalID = id // TODO: what is this?
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
        self.playback.isMuted = isMuted // TODO: what is this?
    }

    func setPlayback(isFullscreen: Bool) {
        self.playback.isFullscreen = isFullscreen
    }

    func setPlayback(previewPosition position: Int) {
        self.playback.previewPosition = UInt32(position) // TODO: why int?
    }

    func setPlayback(currentPosition position: Int) {
        self.playback.currentPosition = UInt32(position) // TODO: why int?
    }

    // MARK: - InnerEventsHandler

    func playback(sec: TimeInterval) {
        service.send(event: build(event: .playback, value: Float(sec))) { _ in

        }
    }

    func play() {
        service.send(event: build(event: .play, value: 0)) { _ in

        }
    }

    func pause() {
        service.send(event: build(event: .pause, value: 0)) { _ in

        }
    }

    func end() {
        service.send(event: build(event: .end, value: 0)) { _ in

        }
    }

    func replay() {
        service.send(event: build(event: .replay, value: 0)) { _ in

        }
    }

    func buffer(sec: TimeInterval) {
        service.send(event: build(event: .buffering, value: Float(sec))) { _ in

        }
    }

    func seek() {
        service.send(event: build(event: .seek, value: 0)) { _ in

        }
    }

    func rate(_ rate: Float) {
        service.send(event: build(event: .rate, value: Float(rate))) { _ in

        }
    }

    func view() {
        service.send(event: build(event: .view, value: 0)) { _ in

        }
    }

    func enterfullscreen() {
        service.send(event: build(event: .enterfullscreen, value: 0)) { _ in

        }
    }

    func exitfullscreen() {
        service.send(event: build(event: .exitfullscreen, value: 0)) { _ in

        }
    }

    func qualitychanged() {
        service.send(event: build(event: .qualitychanged, value: 0)) { _ in

        }
    }

    func autoqualitychanged() {
        service.send(event: build(event: .autoqualitychanged, value: 0)) { _ in

        }
    }
    
}

// MARK: - Private

private extension InnerEventsProtoHandler {

    func send(event: InnerProtoEvent, value: Float) {
        service.send(event: build(event: event, value: value)) { _ in
            
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
