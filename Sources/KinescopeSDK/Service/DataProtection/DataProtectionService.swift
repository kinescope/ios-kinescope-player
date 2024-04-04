//
//  DataProtectionService.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 21.02.2024.
//

import Foundation

/// Service to handle DRM related requests to key server.
protocol DataProtectionService {
    /// - parameter video: Kinescope Video to get certificate for.
    /// - parameter completion: Completion handler to be called with the result.
    func getCert(for video: KinescopeVideo,
                 completion: @escaping (Result<Data, Error>) -> Void)

    /// - parameter video: Kinescope Video to get content key for.
    /// - parameter body: Data protection request body provided by system.
    /// - parameter completion: Completion handler to be called with the result.
    func getContentKey(for video: KinescopeVideo,
                       body: DataProtectionRequestBody,
                       completion: @escaping (Result<DataProtectionResponse, Error>) -> Void)
}
