//
//  KinescopeAnalyticEndpoints.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 04.04.2024.
//

import Foundation

/// `sdk` block of the video metadata.
public struct KinescopeAnalyticEndpoints: Codable {
    let metricUrl: String?
    /// Watermark from the player template. `nil` when the template has none.
    public let watermark: KinescopeWatermark?

    enum CodingKeys: String, CodingKey {
        case metricUrl
        case watermark
    }

    /// A broken watermark must not drop the analytics endpoint, and the reverse.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        metricUrl = try? container.decodeIfPresent(String.self, forKey: .metricUrl)
        watermark = try? container.decodeIfPresent(KinescopeWatermark.self, forKey: .watermark)
    }
}
