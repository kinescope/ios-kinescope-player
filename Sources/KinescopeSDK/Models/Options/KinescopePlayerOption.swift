//
//  KinescopePlayerOption.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 01.04.2021.
//

/// Options available in player control panel
public enum KinescopePlayerOption: String {

    /// Option to expand control panel and show all available options
    case more
    /// Option to open player in fullscreen mode
    case fullscreen
    /// Option to open settings slide menu
    case settings
    /// Option to open attachments list in side menu
    case attachments
    /// Option to open download options list in side menu
    case download
    /// Option to open list of available devices to stream contet from video via AirPlay
    case airPlay
    /// Option to on/off subtitles and choose subtitle language
    case subtitles
}
