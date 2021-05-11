//
//  KinescopeVideoQuality.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 29.03.2021.
//

import Foundation

/// Quality of video to play
public struct KinescopeVideoQuality {

    /// HSL-link to m3u8 file with assets or url to downloaded asset
    let link: String
    /// Link for audio. Optional
    let audio: String?
    /// Link for subtitles. Optional
    let subtitles: String?
    /// Flag representing if this is auto quality
    let isAuto: Bool

}
