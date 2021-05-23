import Foundation

/// Works with asses links
protocol AssetLinksService {
    /// Requests asset link
    /// - Parameters:
    ///   - id: asset id
    ///   - completion: completion block
    func getAssetLink(by id: String, completion: @escaping (Result<KinescopeVideoAssetLink, Error>) -> Void)
}

/// AssetLinksService implementation
final class AssetLinksNetworkService: AssetLinksService {

    // MARK: - Private Properties

    private let transport: Transport
    private let config: KinescopeConfig

    // MARK: - Lifecycle

    init(transport: Transport, config: KinescopeConfig) {
        self.transport = transport
        self.config = config
    }

    // MARK: - Public Methods

    func getAssetLink(by id: String, completion: @escaping (Result<KinescopeVideoAssetLink, Error>) -> Void) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard
                let self = self
            else {
                return
            }

            do {

                let request = try RequestBuilder(path: self.config.endpoint + "/assets/\(id)/link", method: .get)
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
