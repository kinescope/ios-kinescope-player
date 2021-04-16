//
//  KinescopePlayerDependencies.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 29.03.2021.
//

/// Facade for dependencies
protocol KinescopePlayerDependencies: PlayingStrategyProvider {
    var inspector: KinescopeInspectable { get }
    var assetDownloader: KinescopeAssetDownloadable { get }
    var attachmentDownloader: KinescopeAttachmentDownloadable { get }
}
