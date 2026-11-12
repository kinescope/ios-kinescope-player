//
//  KinescopeVideoQuality.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 29.03.2021.
//

import Foundation

/// Quality of video to play
public enum KinescopeVideoQuality {

    /// Automatically selected quality, based on internet connection
    ///
    /// - parameter hlsLink: HSL-link to m3u8 file with assets
    case auto(hlsLink: String)

    /// Exactly selected quality
    ///
    /// - parameter asset: Asset with info about quality required to get link to concrete resource
    case exact(asset: KinescopeVideoAsset)

    /// Exactly selected quality with subtitles
    ///
    /// - parameter asset: Asset with info about quality required to get link to concrete resource
    /// - parameter subtitle: Asset for subtitle
    case exactWithSubtitles(asset: KinescopeVideoAsset, subtitle: KinescopeVideoSubtitle)

    /// Downloaded asset
    ///
    /// - parameter url: URL to asset file in device storage
    case downloaded(url: URL)

    /// Max bitrate for quality
    /// - Returns: Zero when bitRate is not limited.
    var preferredMaxBitRate: Double {
        switch self {
        case .auto, .downloaded:
            return 0
        case .exact(let asset), .exactWithSubtitles(let asset, _):
            return Self.peakBitRate(forHeight: asset.height, name: asset.name)
        }
    }

    /// Caps the picture size so the chosen rendition is the highest one still allowed.
    var preferredMaximumResolution: CGSize {
        switch self {
        case .auto, .downloaded:
            return .zero
        case .exact(let asset), .exactWithSubtitles(let asset, _):
            let side = CGFloat(Self.listedHeight(asset.height, name: asset.name))
            guard side > 0 else {
                return .zero
            }
            return CGSize(width: side * 16 / 9, height: side)
        }
    }

    /// Peak just above the rung, so a 1080 selection can actually reach the 1080 variant.
    private static func peakBitRate(forHeight height: Int, name: String) -> Double {
        switch listedHeight(height, name: name) {
        case 1..<300:
            return 1_000_000
        case 300..<420:
            return 2_000_000
        case 420..<600:
            return 3_000_000
        case 600..<900:
            return 5_500_000
        case 900..<1300:
            return 9_000_000
        case 1300..<1800:
            return 14_000_000
        case 1800...:
            return 28_000_000
        default:
            return 0
        }
    }

    private static func listedHeight(_ height: Int, name: String) -> Int {
        if height > 0 {
            return height
        }
        return Int(name.filter(\.isNumber)) ?? 0
    }

}
