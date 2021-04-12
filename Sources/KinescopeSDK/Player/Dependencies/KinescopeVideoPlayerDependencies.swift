//
//  KinescopeVideoPlayerDependencies.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 29.03.2021.
//

struct KinescopeVideoPlayerDependencies: KinescopePlayerDependencies {

    let inspector: KinescopeInspectable = Kinescope.shared.inspector
    let downloader: KinescopeAssetDownloadable = Kinescope.shared.downloader
    let attachmentDownloader: KinescopeAttachmentDownloadable = Kinescope.shared.attachmentDownloader
    
    // MARK: - PlayingStrategyProvider

    func provide(for config: KinescopePlayerConfig) -> PlayingStrategy {
        if config.looped {
            return LoopedPlayingStrategy()
        } else {
            return SequentialPlayingStrategy()
        }
    }

}
