//
//  PlayingStrategyProvider.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 29.03.2021.
//

/// Protocol for objects that can provide playing stargegy based on player config
protocol PlayingStrategyProvider {
    func provide(for config: KinescopePlayerConfig) -> PlayingStrategy
}
