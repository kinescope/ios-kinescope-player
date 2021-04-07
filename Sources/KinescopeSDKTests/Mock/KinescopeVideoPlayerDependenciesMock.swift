//
//  KinescopeVideoPlayerDependenciesMock.swift
//  KinescopeSDKTests
//
//  Created by Никита Коробейников on 29.03.2021.
//

@testable import KinescopeSDK

struct KinescopeVideoPlayerDependenciesMock: KinescopePlayerDependencies {

    // MARK: - Mock Properties

    let inspectorMock: KinescopeInspectableMock
    let downloaderMock: KinescopeAssetDownloadableMock
    let strategyMock: PlayingStrategyMock

    // MARK: - Mock Implementation

    var inspector: KinescopeInspectable {
        inspectorMock
    }

    var downloader: KinescopeAssetDownloadable {
        downloaderMock
    }

    func provide(for config: KinescopePlayerConfig) -> PlayingStrategy {
        strategyMock
    }

}
