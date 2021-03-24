//
//  Manager+KinescopeConfigurable.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//

// MARK: - KinescopeConfigurable

extension Manager: KinescopeConfigurable {

    func setConfig(_ config: KinescopeConfig) {
        self.config = config
        self.downloader = VideoDownloader(apiKey: config.apiKey)
        self.inspector = Inspector(videosService: .init(transport: Transport(), config: config))
    }

}
