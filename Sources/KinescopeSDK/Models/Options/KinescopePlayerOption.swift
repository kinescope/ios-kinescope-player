//
//  KinescopePlayerOption.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 01.04.2021.
//

import UIKit

/// Options available in player control panel
public enum KinescopePlayerOption {

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
    /// Option to enter in Picture in Picture mode, availalble only if device supported PiP 
    case pip
    /// Custom option to perform any action
    /// - Parameters:
    ///    - id: Uniq identifier to distinguish selection of different button. Maybe `String`, `Int`, `UUID` or other `Hashable`.
    ///    - icon: Image to represent option in menu
    case custom(id: AnyHashable, icon: UIImage)

    // MARK: - Appearance

    var icon: UIImage {
        switch self {
        case .more:
            return UIImage.image(named: "more")
        case .fullscreen:
            return UIImage.image(named: "fullscreen")
        case .settings:
            return UIImage.image(named: "settings")
        case .attachments:
            return UIImage.image(named: "attachments")
        case .download:
            return UIImage.image(named: "download")
        case .airPlay:
            return UIImage.image(named: "airPlay")
        case .subtitles:
            return UIImage.image(named: "subtitles")
        case .pip:
            return UIImage.image(named: "pip")
        case .custom(_, let icon):
            return icon
        }
    }

    var iconSelected: UIImage? {
        switch self {
        case .subtitles:
            return UIImage.image(named: "subtitlesSelected")
        case .airPlay:
            return UIImage.image(named: "airPlayActive")
        case .custom(_, let icon):
            return icon
        default:
            return nil
        }
    }
    
    // MARK: - Id:

    var optionId: AnyHashable? {
        switch self {
        case .custom(let id, _):
            return id
        default:
            return nil
        }
    }

}

// MARK: - Equatable

extension KinescopePlayerOption: Equatable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.more, .more):
            return true
        case (.fullscreen, .fullscreen):
            return true
        case (.settings, .settings):
            return true
        case (.attachments, .attachments):
            return true
        case (.download, .download):
            return true
        case (.airPlay, .airPlay):
            return true
        case (.subtitles, .subtitles):
            return true
        case (.pip, .pip):
            return true
        case (.custom(let lId, _), .custom(let rId, _)):
            return lId == rId
        default:
            return false
        }
    }

}
