//
//  DataProtectionService.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 21.02.2024.
//

import Foundation

/// Service to handle DRM related requests to key server.
protocol DataProtectionService {
    /// - parameter videoId: Kinescope Video identifier to get certificate for.
    /// - parameter completion: Completion handler to be called with the result.
    func getCert(for videoId: String,
                 completion: @escaping (Result<Data, Error>) -> Void)

    /// - parameter videoId: Kinescope Video identifier to get content key for.
    /// - parameter body: Data protection request body provided by system.
    /// - parameter completion: Completion handler to be called with the result.
    func getContentKey(for videoId: String,
                       body: DataProtectionRequestBody,
                       completion: @escaping (Result<DataProtectionResponse, Error>) -> Void)
}
