//
//  Inspector.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//

// MARK: - KinescopeInspectable

class Inspector: KinescopeInspectable {

    // MARK: - Properties

    private let videosService: VideosApiClient

    // MARK: - Initialisation

    init(videosService: VideosApiClient) {
        self.videosService = videosService
    }

    // MARK: - Methods

    func list(onSuccess: (KinescopeVideoListResponse) -> Void, onError: (KinescopeInspectError) -> Void) {
        // TODO: - implement
    }

}
