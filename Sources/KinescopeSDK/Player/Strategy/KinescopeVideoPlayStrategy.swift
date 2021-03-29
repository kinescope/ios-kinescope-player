//
//  KinescopeVideoPlayStrategy.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 29.03.2021.
//

import AVFoundation

protocol KinescopeVideoPlayStrategy {

    var player: AVPlayer { get }

    /// Set AVPlayerItem to `Player`
    ///
    /// - parameter item: AVPlayerItem with resource to play
    func bind(item: AVPlayerItem)

    /// Stop playing. Clear AVPlayer item
    func ubind()
}
