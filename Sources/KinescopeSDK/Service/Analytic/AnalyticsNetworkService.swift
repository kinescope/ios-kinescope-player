//
//  AnalyticsNetworkService.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 02.04.2024.
//

import Foundation

/// Implementation of ``AnalyticsService`` which will send analytic via network to kinescope dashboard
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

    func send(event: Analytics_Native, for video: KinescopeVideo) {
        guard let path = video.analytic?.metricUrl else {
            Kinescope.shared.logger?.log(message: "Could not get analytic endpoint", level: KinescopeLoggerLevel.analytics)
            return
        }

        guard let data = try? event.serializedData() else {
            Kinescope.shared.logger?.log(message: "Could not serialize event", level: KinescopeLoggerLevel.analytics)
            return
        }
        executionQueue.async { [weak self] in
            do {

                let request = try RequestBuilder(path: path, method: .post)
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
