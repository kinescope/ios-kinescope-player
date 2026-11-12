//
//  KinescopeVideoPlayerTests.swift
//  KinescopeSDKTests
//
//  Created by Никита Коробейников on 29.03.2021.
//

import XCTest
import AVFoundation
@testable import KinescopeSDK

final class KinescopeVideoPlayerTests: XCTestCase {

    private enum Constants {
        static let hlsStub = "https://example.com/playlist.m3u8"
        static let videoId = "123"
        static let videoStub: KinescopeVideo = .stub(id: videoId, hlsLink: hlsStub)
    }

    var player: KinescopeVideoPlayer?
    var inspector: KinescopeInspectableMock?
    var downloader: KinescopeAssetDownloadableMock?
    var attachmentDownloader: KinescopeAttachmentDownloaderMock?
    var strategy: PlayingStrategyMock?

    override func setUp() {
        super.setUp()

        let inspector = KinescopeInspectableMock()
        let downloader = KinescopeAssetDownloadableMock()
        let strategy = PlayingStrategyMock()
        let attachmentDownloader = KinescopeAttachmentDownloaderMock()

        let dependencies = KinescopeVideoPlayerDependenciesMock(drmFactoryStub: .init(),
                                                                inspectorMock: inspector,
                                                                assetDownloaderMock: downloader,
                                                                strategyMock: strategy,
                                                                attachmentDownloaderMock: attachmentDownloader)

        self.player = KinescopeVideoPlayer(config: .init(videoId: Constants.videoId),
                                           dependencies: dependencies)

        self.inspector = inspector
        self.strategy = strategy
        self.attachmentDownloader = attachmentDownloader
    }

    override func tearDown() {
        super.tearDown()

        inspector = nil
        strategy = nil
    }

    func testPlayInitiateLoadingAndDelegateToStrategy() {

        // given

        inspector?.videoSuccessMock[Constants.videoId] = Constants.videoStub

        // when

        player?.play()

        // then

        XCTAssertEqual(inspector?.videoRequests.count, 1)
        XCTAssertEqual(strategy?.bindItems.count, 1)
        XCTAssertEqual(strategy?.playCalledCount, 1)
        XCTAssertEqual(strategy?.pauseCalledCount, 0)
        XCTAssertEqual(strategy?.unbindCalledCount, 0)

    }

    func testPauseDelegateToStrategy() {

        // when

        player?.pause()

        // then

        XCTAssertEqual(strategy?.bindItems.count, 0)
        XCTAssertEqual(strategy?.playCalledCount, 0)
        XCTAssertEqual(strategy?.pauseCalledCount, 1)
        XCTAssertEqual(strategy?.unbindCalledCount, 0)
    }

    func testStopDelegateToStrategy() {

        // when

        player?.stop()

        // then

        XCTAssertEqual(strategy?.bindItems.count, 0)
        XCTAssertEqual(strategy?.playCalledCount, 0)
        XCTAssertEqual(strategy?.pauseCalledCount, 1)
        XCTAssertEqual(strategy?.unbindCalledCount, 1)

    }

    func testRepeatedPlayDoesNotBindAgain() {
        inspector?.videoSuccessMock[Constants.videoId] = Constants.videoStub

        player?.play()
        player?.play()

        XCTAssertEqual(inspector?.videoRequests.count, 1)
        XCTAssertEqual(strategy?.bindItems.count, 1)
        XCTAssertEqual(strategy?.playCalledCount, 2)
    }

    func testStopThenPlayBindsOnceMore() {
        inspector?.videoSuccessMock[Constants.videoId] = Constants.videoStub

        player?.play()
        player?.stop()
        player?.play()

        XCTAssertEqual(strategy?.unbindCalledCount, 1)
        XCTAssertEqual(strategy?.bindItems.count, 2)
    }

    func testLoopedRebindDoesNotRaise() {
        let strategy = LoopedPlayingStrategy()
        let first = AVPlayerItem(url: URL(string: "https://example.com/loop.m3u8")!)
        let second = AVPlayerItem(url: URL(string: "https://example.com/loop.m3u8")!)

        strategy.bind(item: first)
        strategy.bind(item: second)
        strategy.unbind()
        strategy.bind(item: AVPlayerItem(url: URL(string: "https://example.com/other.m3u8")!))

        XCTAssertNotNil(strategy.player)
    }

    func testSelectQualityDelegateToStrategy() {
        // given

        let quality: KinescopeVideoQuality = .auto(hlsLink: Constants.hlsStub)

        // when

        player?.select(quality: quality)

        // then

        XCTAssertEqual(strategy?.bindItems.count, 1)
        XCTAssertEqual(strategy?.playCalledCount, 0)
        XCTAssertEqual(strategy?.pauseCalledCount, 0)
        XCTAssertEqual(strategy?.unbindCalledCount, 0)
    }
}
