//
//  KinescopeVideoPlayerTests.swift
//  KinescopeSDKTests
//
//  Created by Никита Коробейников on 29.03.2021.
//

import XCTest
@testable import KinescopeSDK

final class KinescopeVideoPlayerTests: XCTestCase {

    var player: KinescopeVideoPlayer?
    var inspector: KinescopeInspectableMock?
    var strategy: PlayingStrategyMock?

    override func setUp() {
        super.setUp()

        let inspector = KinescopeInspectableMock()
        let strategy = PlayingStrategyMock()
        self.player = KinescopeVideoPlayer(config: .init(videoId: "123"), dependencies: KinescopeVideoPlayerDependenciesMock(inspectorMock: inspector, strategyMock: strategy))

        self.inspector = inspector
        self.strategy = strategy
    }

    override func tearDown() {
        super.tearDown()

        inspector = nil
        strategy = nil
    }
}
