//
//  PlaybackAnalyticDataFactory.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 12.03.2024.
//

import AVFoundation

final class PlaybackAnalyticDataFactory: Factory {
    typealias T = Analytics_Playback
    
    // MARK: - Properties

    private weak var player: AVPlayer?
    private weak var qualityProvider: QualitySelectionProvider?
    private weak var fullscreenStateProvider: FullscreenStateProvider?

    func provide() -> T? {
        guard let player else {
            return nil
        }

        var result = T()
        
        result.rate = player.rate
        result.volume = Int32(player.volume * 100)
        result.isMuted = player.volume == .zero

        if let currentItem = player.currentItem {
            result.currentPosition = UInt32(currentItem.currentTime().seconds)
            result.previewPosition = UInt32(currentItem.buferredSeconds)
        }

        if let qualityProvider {
            result.quality = qualityProvider.currentQuality
        }
        
        if let fullscreenStateProvider {
            result.isFullscreen = fullscreenStateProvider.isFullScreenModeActive
        }

        return result
    }
}
