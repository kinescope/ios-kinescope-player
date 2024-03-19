//
//  AnalyticsService.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 27.04.2021.
//

import Foundation

protocol AnalyticsService {
    func send(event: Analytics_Native)
}

final class AnalyticsNetworkService: AnalyticsService {

    // MARK: - Private Properties

    private let transport: Transport
    private let config: KinescopeConfig

    private let executionQueue = DispatchQueue.global(qos: .utility)

    // MARK: - Lifecycle

    init(transport: Transport, config: KinescopeConfig) {
        self.transport = transport
        self.config = config
    }

    // MARK: - Public Methods

    func send(event: Analytics_Native) {
        guard let data = try? event.serializedData() else {
            Kinescope.shared.logger?.log(message: "Could not serialize event", level: KinescopeLoggerLevel.analytics)
            return
        }
        executionQueue.async { [weak self] in
            do {

                let request = try RequestBuilder(path: "https://metrics.kinescope.io/player-native", method: .post)
                    .build(body: data)

                self?.transport.performRaw(request: request, completion: { result in
                    switch result {
                    case .success:
                        Kinescope.shared.logger?.log(message: "Analytic event '\(event.event)' sended successfully.", level: KinescopeLoggerLevel.analytics)
                    case .failure(let error):
                        Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.analytics)
                    }
                })
            } catch let error {
                Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.analytics)
            }
        }
    }
}
