//
//  Inspector.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//

import GoSwiftyM3U8

/// Base KinescopeInspectable implementation
class Inspector: KinescopeInspectable {

    // MARK: - Properties

    private let videosService: VideosService

    // MARK: - Initialisation

    init(videosService: VideosService) {
        self.videosService = videosService
    }

    // MARK: - KinescopeInspectable

    func list(request: KinescopeVideosRequest,
              onSuccess: @escaping (([KinescopeVideo], KinescopeMetaData)) -> Void,
              onError: @escaping (KinescopeInspectError) -> Void) {
        videosService.getAll(request: request) { result in
            switch result {
            case .success(let response):
                onSuccess((response.data, response.meta))
            case .failure(let error):
                onError(Inspector.parse(error: error))
            }
        }
    }

    func video(id: String,
               onSuccess: @escaping (KinescopeVideo) -> Void,
               onError: @escaping (KinescopeInspectError) -> Void) {
        videosService.getVideo(by: id) { result in
            switch result {
            case .success(let response):
                onSuccess(response)
            case .failure(let error):
                onError(Inspector.parse(error: error))
            }
        }
    }

    func fetchPlaylist(link: String, completion: @escaping (M3U8Manager.Result<MasterPlaylist>) -> (Void)) {
        videosService.fetchPlaylist(link: link, completion: completion)
    }
}

// MARK: - Private

private extension Inspector {

    static func parse(error: Error) -> KinescopeInspectError {
        guard let serverError = error as? ServerError else {
            return .unknown(error)
        }

        switch serverError.code {
        case 404:
            return .notFound
        case 403:
            return .denied
        case ..<0:
            return .network
        default:
            return .unknown(error)
        }
    }

}
