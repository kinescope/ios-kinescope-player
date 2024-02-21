//
//  DataProtectionService.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 20.02.2024.
//

import AVFoundation

/// Binding with AVURLAsset to handle DRM protected content.
public protocol DataProtectionHandler {
    /// - parameter asset: `AVURLAsset` instance to bind with.
    func bind(with asset: AVURLAsset)
}
