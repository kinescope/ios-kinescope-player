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

    func list(onSuccess: @escaping (([KinescopeVideo], KinescopeMetaData?)) -> Void,
              onError: @escaping (KinescopeInspectError) -> Void) {
        videosService.getAll(request: .init(page: 1, perPage: 5, order: nil)) { result in
            switch result {
            case .success(let response):
                onSuccess((response.data, response.meta))
            case .failure(let error):
                onError(.from(error: error))
            }
        }
    }

}

// MARK: - Private

private extension KinescopeInspectError {

    static func from(error: Error) -> KinescopeInspectError {
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
