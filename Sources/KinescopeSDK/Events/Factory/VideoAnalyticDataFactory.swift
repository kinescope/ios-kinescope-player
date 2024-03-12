//
//  VideoAnalyticDataFactory.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 12.03.2024.
//

import Foundation

final class VideoAnalyticDataFactory: Factory {
    typealias T = Analytics_Video
    
    // MARK: - Properties
    
    private var video: KinescopeVideo?

    // MARK: - Factory

    func provide() -> T? {
        guard let video else {
            return nil
        }
        var result = T()
        result.source = video.hlsLink
        result.duration = UInt32(video.duration)
        return result
    }
}
