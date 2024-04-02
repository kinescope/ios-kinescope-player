//
//  KinescopeVideoPlayerDependenciesMock.swift
//  KinescopeSDKTests
//
//  Created by Никита Коробейников on 29.03.2021.
//

@testable import KinescopeSDK

struct KinescopeVideoPlayerDependenciesMock: KinescopePlayerDependencies {

    // MARK: - Mock Properties
    
    let drmFactoryStub: DataProtectionHandlerFactoryStub
    let inspectorMock: KinescopeInspectableMock
    let assetDownloaderMock: KinescopeAssetDownloadableMock
    let strategyMock: PlayingStrategyMock
    let attachmentDownloaderMock: KinescopeAttachmentDownloaderMock

    // MARK: - Mock Implementation
    
    var drmFactory: DataProtectionHandlerFactory {
        drmFactoryStub
    }

    var inspector: KinescopeInspectable {
        inspectorMock
    }

    var assetDownloader: KinescopeAssetDownloadable {
        assetDownloaderMock
    }

    func provide(for config: KinescopePlayerConfig) -> PlayingStrategy {
        strategyMock
    }

    var attachmentDownloader: KinescopeAttachmentDownloadable {
        attachmentDownloaderMock
    }

}
