//
//  AnalyticsService.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 27.04.2021.
//

import Foundation

protocol AnalyticsService {
    func send(event: Analytics_Native, completion: @escaping (Result<Int, Error>) -> Void)
}

final class AnalyticsNetworkService: AnalyticsService {

    // MARK: - Private Properties

    private let transport: Transport
    private let config: KinescopeConfig

    // MARK: - Lifecycle

    init(transport: Transport, config: KinescopeConfig) {
        self.transport = transport
        self.config = config
    }

    // MARK: - Public Methods

    func send(event: Analytics_Native, completion: @escaping (Result<Int, Error>) -> Void) {
        guard let data = try? event.serializedData() else {
            Kinescope.shared.logger?.log(message: "Could not serialize event", level: KinescopeLoggerLevel.network)
            return
        }
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard
                let self = self
            else {
                return
            }

            do {

                let request = try RequestBuilder(path: "https://metrics.kinescope.io/player-native", method: .post)
                    .add(token: self.config.apiKey)
                    .build(body: data)

                self.transport.perform(request: request, completion: completion)
            } catch let error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
