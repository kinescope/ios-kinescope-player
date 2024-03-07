//
//  KinescopeDataProtectionError.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 20.02.2024.
//

import Foundation

enum KinescopeDataProtectionError: Error {
    case unableToReadContentId

    case registraionRequestFailed(Error?)
    case certificateRequetFailed(Error?)
    case contentKeyRequestFailed(Error?)

    case cannotEncodeSPC
    case cannotDecodeCKC

    @available(*, deprecated, message: "Remove it")
    case unableToCreateContentKeyRequest
}
