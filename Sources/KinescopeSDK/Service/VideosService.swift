import Foundation

protocol VideosService {
    func getVideo(by id: String,
                  completion: @escaping (Result<KinescopeVideo, Error>) -> Void)
}

final class VideosNetworkService: VideosService {

    // MARK: - Private Properties

    private let transport: Transport
    private let config: KinescopeConfig
    
    private let executionQueue = DispatchQueue.global(qos: .utility)
    private let errorQueue = DispatchQueue.main

    // MARK: - Lifecycle

    init(transport: Transport, config: KinescopeConfig) {
        self.transport = transport
        self.config = config
    }

    // MARK: - Public Methods

    func getVideo(by id: String, completion: @escaping (Result<KinescopeVideo, Error>) -> Void) {
        executionQueue.async { [weak self] in
            self?.getVideoFromJson(by: id, completion: completion)
        }
    }
}

// MARK: - Private Methods

private extension VideosNetworkService {

    func getVideoFromJson(by id: String, completion: @escaping (Result<KinescopeVideo, Error>) -> Void) {
        do {
            let request = try RequestBuilder(path: "\(config.endpoint)\(id).json", method: .get)
                .add(referer: config.referer)
                .add(parameters: ["sdk": "ios"])
                .build(body: EmptyRequest())

            transport.performFetch(request: request, completion: completion)
        } catch let error {
            errorQueue.async {
                completion(.failure(error))
            }
        }
    }

}
