//
//  PlayerViewState.swift
//  KinescopeSDK
//
//  Created by Никита Гагаринов on 30.04.2021.
//

import Foundation

/// Player view possible states
enum PlayerViewState {
    case initialLoading
    case loading
    case playing
    case paused
    case error
    case ended
}
