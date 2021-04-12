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

    /// Exatcly selected quality
    ///
    /// - parameter asset: Asset with info about quality and link to concrete resource
    case exact(asset: KinescopeVideoAsset)

    /// Dowloaded asset
    ///
    /// - parameter url: URL to asset file in device storage
    case downloaded(url: URL)
}
