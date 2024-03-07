//
//  DataProtectionResponse.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 21.02.2024.
//

import Foundation

/// Response body for the data protection service.
struct DataProtectionResponse: Codable {
    /// Base64 encoded string content key provided by key server,
    let ckc: String
}
