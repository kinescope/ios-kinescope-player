//
//  PlayingStrategyProvider.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 29.03.2021.
//

protocol PlayingStrategyProvider {
    func provide(for config: KinescopePlayerConfig) -> PlayingStrategy
}
