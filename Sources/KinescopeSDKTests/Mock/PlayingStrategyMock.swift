//
//  PlayingStrategyMock.swift
//  KinescopeSDKTests
//
//  Created by Никита Коробейников on 29.03.2021.
//

@testable import KinescopeSDK
import AVFoundation

final class PlayingStrategyMock: PlayingStrategy {

    // MARK: - Spy Properties

    private(set) var bindItems = [AVPlayerItem]()
    private(set) var unbindCalledCount = 0
    private(set) var playCalledCount = 0
    private(set) var pauseCalledCount = 0

    // MARK: - Required Properties

    let player = AVPlayer()

    // MARK: - Methods

    func bind(item: AVPlayerItem) {
        bindItems.append(item)
    }

    func unbind() {
        unbindCalledCount += 1
    }

    func play() {
        playCalledCount += 1
    }

    func pause() {
        pauseCalledCount += 1
    }
}
