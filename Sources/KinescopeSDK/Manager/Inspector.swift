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

    func video(id: String,
               onSuccess: @escaping (KinescopeVideo) -> Void,
               onError: @escaping (KinescopeInspectError) -> Void) {
        video(id: id, drmAuthToken: nil, onSuccess: onSuccess, onError: onError)
    }

    func video(id: String,
               drmAuthToken: String?,
               onSuccess: @escaping (KinescopeVideo) -> Void,
               onError: @escaping (KinescopeInspectError) -> Void) {
        videosService.getVideo(by: id, drmAuthToken: drmAuthToken) { result in
            switch result {
            case .success(let response):
                onSuccess(response)
            case .failure(let error):
                onError(Inspector.parse(error: error))
            }
        }
    }
}

// MARK: - Private

private extension Inspector {

    static func parse(error: Error) -> KinescopeInspectError {
        guard let serverError = error as? ServerError else {
            return .unknown(error)
        }

        switch serverError.code {
        case 404, 4040404:
            return .notFound
        case 403, 4030403:
            return .denied
        case ..<0:
            return .network
        default:
            if serverError.code / 10_000 == 404 {
                return .notFound
            }
            if serverError.code / 10_000 == 403 {
                return .denied
            }
            return .unknown(error)
        }
    }

}
