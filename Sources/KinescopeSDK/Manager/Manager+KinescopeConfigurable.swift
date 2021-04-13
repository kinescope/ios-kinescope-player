//
//  Manager+KinescopeConfigurable.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//

// MARK: - KinescopeConfigurable
import Foundation

extension Manager: KinescopeConfigurable {

    func setConfig(_ config: KinescopeConfig) {
        self.config = config
        self.assetDownloader = AssetDownloader(assetPathsStorage: VideoPathsUDStorage(),
                                               assetService: AssetNetworkService(
                                                assetLinksService: AssetLinksNetworkService(transport: Transport(), config: config)))
        self.attachmentDownloader = AttachmentDownloader(fileService: FileNetworkService())
        self.inspector = Inspector(videosService: VideosNetworkService(transport: Transport(),
                                                                       config: config))
    }

    func set(logger: KinescopeLogging, levels: [KinescopeLoggingLevel]) {
        self.logger = KinescopeLogger(logger: logger, levels: levels)
    }
}
