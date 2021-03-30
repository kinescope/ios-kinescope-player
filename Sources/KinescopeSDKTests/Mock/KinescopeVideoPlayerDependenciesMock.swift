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
    let strategyMock: PlayingStrategyMock

    // MARK: - Mock Implementation

    var inspector: KinescopeInspectable {
        inspectorMock
    }

    func provide(for config: KinescopePlayerConfig) -> PlayingStrategy {
        strategyMock
    }

}
