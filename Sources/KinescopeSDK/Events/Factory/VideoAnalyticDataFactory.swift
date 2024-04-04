//
//  VideoAnalyticDataFactory.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 12.03.2024.
//

import Foundation

protocol VideoAnalyticInput {
    func setVideo(_ video: KinescopeVideo)
}

final class VideoAnalyticDataFactory: Factory {
    typealias T = Analytics_Video
    
    // MARK: - Properties
    
    private(set) var source: KinescopeVideo?

    // MARK: - Factory

    func provide() -> T? {
        guard let source else {
            return nil
        }
        var result = T()
        result.source = source.hlsLink
        result.duration = UInt32(source.duration)
        return result
    }
}

// MARK: - VideoAnalyticInput

extension VideoAnalyticDataFactory: VideoAnalyticInput {
    func setVideo(_ video: KinescopeVideo) {
        self.source = video
    }
}
