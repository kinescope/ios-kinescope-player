//
//  KinescopeVideoQuality.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 29.03.2021.
//

/// Quality of video to play
public enum KinescopeVideoQuality {

    /// Automatically selected quality, based on internet connection
    ///
    /// - parameter hlsLink: HSL-link to m3u8 file with assets
    case auto(hlsLink: String)

    /// Exactly selected quality
    ///
    /// - parameter asset: Asset with info about quality and link to concrete resource
    case exact(asset: KinescopeVideoAsset)

    /// Exactly selected quality with subtitles
    ///
    /// - parameter asset: Asset with info about quality and link to concrete resource
    /// - parameter subtitle: Asset for subtitle
    case exactWithSubtitles(asset: KinescopeVideoAsset, subtitle: KinescopeVideoSubtitle)
}
