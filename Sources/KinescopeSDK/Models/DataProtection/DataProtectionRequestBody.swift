//
//  DataProtectionRequestBody.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 21.02.2024.
//

import Foundation

/// Request body for the data protection service.
struct DataProtectionRequestBody: Codable {
    /// Base64 encoded string data provided by system.
    let spc: String
}
