//
//  Strings.swift
//  KinescopeSDK
//
//  Created by Никита Гагаринов on 23.04.2021.
//

import Foundation

// swiftlint:disable all

// MARK: - Strings

internal enum L10n {

    enum Player {
        /// Soon
        internal static let soon = L10n.tr("Localizable", "Player.soon")
        /// Play
        internal static let play = L10n.tr("Localizable", "Player.play")
        /// Pause
        internal static let pause = L10n.tr("Localizable", "Player.pause")
        /// Replay
        internal static let replay = L10n.tr("Localizable", "Player.replay")
        /// Stop
        internal static let stop = L10n.tr("Localizable", "Player.stop")
        /// Mute
        internal static let mute = L10n.tr("Localizable", "Player.mute")
        /// Unmute
        internal static let unmute = L10n.tr("Localizable", "Player.unmute")
        /// Settings
        internal static let settings = L10n.tr("Localizable", "Player.settings")
        /// Full screen
        internal static let fullscreen = L10n.tr("Localizable", "Player.fullscreen")
        /// Exit full screen
        internal static let exitFullscreen = L10n.tr("Localizable", "Player.exitFullscreen")
        /// Auto
        internal static let auto = L10n.tr("Localizable", "Player.auto")
        /// Error
        internal static let error = L10n.tr("Localizable", "Player.error")
        /// Video playback failed
        internal static let videoPlaybackFailed = L10n.tr("Localizable", "Player.videoPlaybackFailed")
        /// Please try again
        internal static let tryAgain = L10n.tr("Localizable", "Player.tryAgain")
        /// Refresh
        internal static let refresh = L10n.tr("Localizable", "Player.refresh")
        /// Version
        internal static let version = L10n.tr("Localizable", "Player.version")
        /// Chapters
        internal static let chapters = L10n.tr("Localizable", "Player.chapters")
        /// Subtitles
        internal static let subtitles = L10n.tr("Localizable", "Player.subtitles")
        /// Playlist
        internal static let playlist = L10n.tr("Localizable", "Player.playlist")
        /// Download
        internal static let download = L10n.tr("Localizable", "Player.download")
        /// Attachments
        internal static let attachments = L10n.tr("Localizable", "Player.attachments")
        /// Live
        internal static let live = L10n.tr("Localizable", "Player.live")
        /// Skip ahead to live broadcast
        internal static let LiveTooltip = L10n.tr("Localizable", "Player.LiveTooltip")
        /// Off
        internal static let off = L10n.tr("Localizable", "Player.off")
        /// Share
        internal static let share = L10n.tr("Localizable", "Player.share")
        /// AirPlay
        internal static let airplay = L10n.tr("Localizable", "Player.airplay")
        /// Additional materials
        internal static let additionalMaterials = L10n.tr("Localizable", "Player.additionalMaterials")
        /// Download All
        internal static let downloadAll = L10n.tr("Localizable", "Player.downloadAll")
        /// Playback speed
        internal static let playbackSpeed = L10n.tr("Localizable", "Player.playbackSpeed")
        /// Quality
        internal static let videoQuality = L10n.tr("Localizable", "Player.videoQuality")
        /// Normal
        internal static let normal = L10n.tr("Localizable", "Player.normal")
        /// Save log
        internal static let saveLogToFile = L10n.tr("Localizable", "Player.saveLogToFile")
        /// About Kinescope
        internal static let aboutCompany = L10n.tr("Localizable", "Player.aboutCompany")
        /// Show
        internal static let show = L10n.tr("Localizable", "Player.show")
        /// Hide
        internal static let hide = L10n.tr("Localizable", "Player.hide")
        /// Reset
        internal static let reset = L10n.tr("Localizable", "Player.reset")
        /// Options
        internal static let options = L10n.tr("Localizable", "Player.options")
        /// %d s
        internal static func seconds(_ p1: Int) -> String {
            L10n.tr("Localizable", "Player.seconds", p1)
        }
        /// Playback stalled. Check your internet connection
        internal static let playbackStalled = L10n.tr("Localizable", "Player.playbackStalled")
        /// Audio
        internal static let audio = L10n.tr("Localizable", "Player.audio")
        /// Track %d
        internal static func audioTrack(_ p1: Int) -> String {
            L10n.tr("Localizable", "Player.audioTrack", p1)
        }
        /// Reset video scale
        internal static let resetScale = L10n.tr("Localizable", "Player.resetScale")
        /// Scale
        internal static let scale = L10n.tr("Localizable", "Player.scale")
        /// − 3%
        internal static let scaleDecrease = L10n.tr("Localizable", "Player.scaleDecrease")
        /// + 3%
        internal static let scaleIncrease = L10n.tr("Localizable", "Player.scaleIncrease")
        /// 100%
        internal static let scaleReset = L10n.tr("Localizable", "Player.scaleReset")
        /// %d videos
        internal static func playlistCount(_ p1: Int) -> String {
            L10n.tr("Localizable", "Player.playlistCount", p1)
        }
        /// Awaiting broadcast
        internal static let liveAwaiting = L10n.tr("Localizable", "Player.liveAwaiting")
        /// Live broadcast in %d min
        internal static func liveInMinutes(_ p1: Int) -> String {
            L10n.tr("Localizable", "Player.liveInMinutes", p1)
        }
        /// Live broadcast in %d hr
        internal static func liveInHours(_ p1: Int) -> String {
            L10n.tr("Localizable", "Player.liveInHours", p1)
        }
        /// Live broadcast in %d days
        internal static func liveInDays(_ p1: Int) -> String {
            L10n.tr("Localizable", "Player.liveInDays", p1)
        }
        internal static let subtitleLook = L10n.tr("Localizable", "Player.subtitleLook")
        internal static let fontColor = L10n.tr("Localizable", "Player.fontColor")
        internal static let fontSize = L10n.tr("Localizable", "Player.fontSize")
        internal static let backgroundColor = L10n.tr("Localizable", "Player.backgroundColor")
        internal static let backgroundOpacity = L10n.tr("Localizable", "Player.backgroundOpacity")
        internal static let subtitleSearch = L10n.tr("Localizable", "Player.subtitleSearch")
        internal static let colorWhite = L10n.tr("Localizable", "Player.colorWhite")
        internal static let colorGreen = L10n.tr("Localizable", "Player.colorGreen")
        internal static let colorCyan = L10n.tr("Localizable", "Player.colorCyan")
        internal static let colorBlue = L10n.tr("Localizable", "Player.colorBlue")
        internal static let colorMagenta = L10n.tr("Localizable", "Player.colorMagenta")
        internal static let colorRed = L10n.tr("Localizable", "Player.colorRed")
        internal static let colorBlack = L10n.tr("Localizable", "Player.colorBlack")
        /// Double tap ± 10 sec
        internal static let scrubHint = L10n.tr("Localizable", "Player.scrubHint")
    }

}

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    // Find localizable file in client, if key == clientFormat => there is no such file in client
    let clientFormat = Bundle.main.localizedString(forKey: key, value: nil, table: "KinescopeLocalizable")
    if clientFormat != key {
        return String(format: clientFormat, locale: Locale.current, arguments: args)
    }
    let sdkFormat = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: sdkFormat, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {
  static let bundle: Bundle = {
    var bundle: Bundle
    #if SWIFT_PACKAGE
    bundle = Bundle.module
    #else
    bundle = Bundle(for: BundleToken.self)
    #endif
    if let resource = bundle.resourcePath, let resourceBundle = Bundle(path: resource + "/KinescopeSDK.bundle") {
        bundle = resourceBundle
    }
    return bundle
  }()
}
