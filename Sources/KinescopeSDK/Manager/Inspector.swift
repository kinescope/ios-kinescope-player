//
//  Inspector.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//

// MARK: - KinescopeInspectable

class Inspector: KinescopeInspectable {

    // MARK: - Properties

    private let videosService: VideosService

    // MARK: - Initialisation

    init(videosService: VideosService) {
        self.videosService = videosService
    }

    // MARK: - Methods

    func list(onSuccess: ([KinescopeVideo]) -> Void, onError: (KinescopeInspectError) -> Void) {
        preconditionFailure("Implement")
    }

}
