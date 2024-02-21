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

    private let executionQueue = DispatchQueue.global(qos: .utility)
    private let errorQueue = DispatchQueue.main

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
        executionQueue.async { [weak self] in
            do {

                let request = try RequestBuilder(path: "https://metrics.kinescope.io/player-native", method: .post)
                    .build(body: data)

                self?.transport.perform(request: request, completion: completion)
            } catch let error {
                self?.errorQueue.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
