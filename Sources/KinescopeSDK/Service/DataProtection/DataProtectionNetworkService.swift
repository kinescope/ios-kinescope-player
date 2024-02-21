//
//  DataProtectionNetworkService.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 21.02.2024.
//

import Foundation

final class DataProtectionNetworkService: DataProtectionService {

    // MARK: - Private Properties

    private let transport: Transport
    private let config: KinescopeConfig

    // MARK: - Lifecycle

    init(transport: Transport, config: KinescopeConfig) {
        self.transport = transport
        self.config = config
    }

    // MARK: - Public Methods

    func getCert(for videoId: String, completion: @escaping (Result<Data, Error>) -> Void) {
        do {
            let url = URL(string: "\(config.keyServer)\(videoId)/certificate/fairplay")!
            let data = try Data(contentsOf: url)
            completion(.success(data))
        } catch let error {
            completion(.failure(error))
        }
    }

    func getContentKey(for videoId: String, body: DataProtectionRequestBody, completion: @escaping (Result<DataProtectionResponse, Error>) -> Void) {
        do {
            let request = try RequestBuilder(path: "\(config.keyServer)\(videoId)/acquire/fairplay",
                                             method: .post)
                .build(body: body)

            transport.performFetch(request: request, completion: completion)
        } catch let error {
            completion(.failure(error))
        }
    }

}
