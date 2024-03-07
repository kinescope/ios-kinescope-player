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
            switch asset.name {
            case "240p":
                return 700000
            case "360p":
                return 1500000
            case "480p":
                return 2000000
            case "720p":
                return 4000000
            case "1080p":
                return 6000000
            default:
                return 0
            }
        }
    }

}
