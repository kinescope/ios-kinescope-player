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
    /// - parameter id: ID of video
    /// - parameter asset: Asset with info about quality required to get link to concrete resource
    case exact(id: String, asset: KinescopeVideoAsset)

    /// Exactly selected quality with subtitles
    ///
    /// - parameter id: ID of video
    /// - parameter asset: Asset with info about quality required to get link to concrete resource
    /// - parameter subtitle: Asset for subtitle
    case exactWithSubtitles(id: String, asset: KinescopeVideoAsset, subtitle: KinescopeVideoSubtitle)

    /// Downloaded asset
    ///
    /// - parameter url: URL to asset file in device storage
    case downloaded(url: URL)

}
