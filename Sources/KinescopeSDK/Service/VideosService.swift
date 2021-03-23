import Foundation

final class VideosService {

    // MARK: - Private Properties

    private let transport: Transport
    private let config: KinescopeConfig

    // MARK: - Lifecycle

    init(transport: Transport, config: KinescopeConfig) {
        self.transport = transport
        self.config = config
    }

    // MARK: - Public Methods

    func getAll(request: KinescopeVideosRequest, completion: @escaping (Result<[KinescopeVideo], Error>) -> Void) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }
            do {
                let requestData = try JSONEncoder().encode(request)
                let requestDictionary = try JSONSerialization.jsonObject(with: requestData) as? [String: Any] ?? [:]
                let params = requestDictionary.compactMapValues { String(describing: $0) }

                let request = try RequestBuilder(path: self.config.endpoint + "/videos", method: .get)
                    .add(token: self.config.apiKey)
                    .add(parameters: params)
                    .build(body: EmptyRequest())

                self.transport.perform(request: request, completion: completion)
            } catch let error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func getVideo(by id: String, completion: @escaping (Result<KinescopeVideo, Error>) -> Void) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }
            do {

                let request = try RequestBuilder(path: self.config.endpoint + "/videos/\(id)", method: .get)
                    .add(token: self.config.apiKey)
                    .build(body: EmptyRequest())

                self.transport.perform(request: request, completion: completion)
            } catch let error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
