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

    private let executionQueue = DispatchQueue.global(qos: .utility)
    private let errorQueue = DispatchQueue.main

    // MARK: - Lifecycle

    init(transport: Transport) {
        self.transport = transport
    }

    // MARK: - Public Methods

    func getCert(for video: KinescopeVideo, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let path = video.drm?.fairplay.certificateUrl,
              let url = URL(string: path) else {
            Kinescope.shared.logger?.log(message: "Could not get drm certificate endpoint", level: KinescopeLoggerLevel.drm)
            return
        }

        executionQueue.async { [weak self] in
            guard let self else {
                return
            }
            do {
                let data = try Data(contentsOf: url)
                completion(.success(data))
            } catch let error {
                errorQueue.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func getContentKey(for video: KinescopeVideo, body: DataProtectionRequestBody, completion: @escaping (Result<DataProtectionResponse, Error>) -> Void) {
        guard let path = video.drm?.fairplay.licenseUrl else {
            Kinescope.shared.logger?.log(message: "Could not get drm license endpoint", level: KinescopeLoggerLevel.drm)
            return
        }

        executionQueue.async { [weak self] in
            guard let self else {
                return
            }
            do {
                let request = try RequestBuilder(path: path,
                                                 method: .post)
                    .build(body: body)

                transport.performFetch(request: request, completion: completion)
            } catch let error {
                errorQueue.async {
                    completion(.failure(error))
                }
            }
        }
    }

}
