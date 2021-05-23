import Foundation
import GoSwiftyM3U8

typealias AllVideosResponse = MetaResponse<[KinescopeVideo], KinescopeMetaData>

/// Works with video models download
protocol VideosService {
    /// Loads video models list
    /// - Parameters:
    ///   - request: request model
    ///   - completion: completion block
    func getAll(request: KinescopeVideosRequest,
                completion: @escaping (Swift.Result<AllVideosResponse, Error>) -> Void)
    /// Loads concrete video model
    /// - Parameters:
    ///   - id: video id
    ///   - completion: completion block
    func getVideo(by id: String,
                  completion: @escaping (Swift.Result<KinescopeVideo, Error>) -> Void)
    /// Loads m3u8 manifest for video
    /// - Parameters:
    ///   - link: link to video/manifest
    ///   - completion: completion block
    func fetchPlaylist(link: String,
                       completion: @escaping (M3U8Manager.Result<MasterPlaylist>) -> (Void))
}

/// VideosService implementation
final class VideosNetworkService: VideosService {

    // MARK: - Private Properties

    private let transport: Transport
    private let config: KinescopeConfig

    // MARK: - Lifecycle

    init(transport: Transport, config: KinescopeConfig) {
        self.transport = transport
        self.config = config
    }

    // MARK: - Public Methods

    func getAll(request: KinescopeVideosRequest,
                completion: @escaping (Swift.Result<AllVideosResponse, Error>) -> Void) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard
                let self = self
            else {
                return
            }

            do {
                let encoder = JSONEncoder()
                encoder.keyEncodingStrategy = .convertToSnakeCase
                let requestData = try encoder.encode(request)

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

    func getVideo(by id: String, completion: @escaping (Swift.Result<KinescopeVideo, Error>) -> Void) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard
                let self = self
            else {
                return
            }

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

    func fetchPlaylist(link: String, completion: @escaping (M3U8Manager.Result<MasterPlaylist>) -> (Void)) {
        guard let url = URL(string: link) else {
            return
        }
        let manager = M3U8Manager()
        let params = PlaylistOperation.Params(fetcher: nil, url: url, playlistType: .master)
        let operationData = M3U8Manager.PlaylistOperationData(params: params)
        manager.fetchAndParsePlaylist(from: operationData, playlistType: MasterPlaylist.self, completionHandler: completion)
    }

    // MARK: - Private

    private func fetchPlaylists(videos: [KinescopeVideo],
                                completion: @escaping (M3U8Manager.Result<[MediaPlaylist]>) -> (Void)) {
        let manager = M3U8Manager()

        let operationsData = videos.compactMap { video -> M3U8Manager.PlaylistOperationData? in
            guard let url = URL(string: video.hlsLink) else {
                return nil
            }
            let params = PlaylistOperation.Params(fetcher: nil, url: url, playlistType: .master)
            let parserExtraParams = M3U8Parser.ExtraParams(customRequiredTags: nil, extraTypes: nil, linePostProcessHandler: nil)
            let extraParams = PlaylistOperation.ExtraParams(parser: parserExtraParams)
            let operationData = M3U8Manager.PlaylistOperationData(params: params, extraParams: extraParams)
            return operationData
        }


        manager.fetchAndParseMediaPlaylists(from: operationsData, completionHandler: completion)
    }

}
