//
//  KinescopeVideoQuality.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 29.03.2021.
//

import AVFoundation

/// Player item configutation
public protocol KinescopeVideoQuality {
    /// Builded AVPlayerItem
    var item: AVPlayerItem? { get }
    /// Flag pointing if this is auto quality
    var isAuto: Bool { get }
    /// Flag pointing if this is online stream not offline
    var isOnline: Bool { get }
}

/// Quality for hls streams
public struct KinescopeStreamVideoQuality: KinescopeVideoQuality {

    /// Url to hls stream
    public let hlsLink: String
    /// Audio locale string. en-EN like
    public let audioLocale: String?
    /// Subtitles locale string. en-EN like
    public let subtitlesLocale: String?

    // MARK: - KinescopeVideoQuality

    public let isAuto: Bool
    public var isOnline: Bool {
        return true
    }
    public var item: AVPlayerItem? {
        return makeItem()
    }

    // MARK: - Private

    private func makeItem() -> AVPlayerItem? {
        let asset = AVURLAsset(url: URL(string: hlsLink)!)
        let playerItem = AVPlayerItem(asset: asset)
        if let audioLocale = audioLocale {
            if let group = asset.mediaSelectionGroup(forMediaCharacteristic: .audible) {
                let locale = Locale(identifier: audioLocale)
                let options =
                    AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, with: locale)
                if let option = options.first {
                    playerItem.select(option, in: group)
                }
            }
        }
        if let subtitlesLocale = subtitlesLocale {
            if let group = asset.mediaSelectionGroup(forMediaCharacteristic: .legible) {
                let locale = Locale(identifier: subtitlesLocale)
                let options =
                    AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, with: locale)
                if let option = options.first {
                    playerItem.select(option, in: group)
                }
            }
        }
        return playerItem
    }

}

/// Quality builded from assets
public struct KinescopeAssetVideoQuality: KinescopeVideoQuality {

    /// Link to asset
    public let video: String
    /// Link for audio. Optional
    public let audio: String?
    /// Link for subtitles. Optional
    public let subtitles: String?

    // MARK: - KinescopeVideoQuality

    public var item: AVPlayerItem? {
        return makeItem()
    }
    public var isAuto: Bool {
        return false
    }
    public var isOnline: Bool {
        return false
    }

    // MARK: - Private

    private func makeItem() -> AVPlayerItem? {
        guard let url = URL(string: video) else {
            return nil
        }

        let composition = AVMutableComposition()

        // Video

        let videoAsset = AVURLAsset(url: url)
        let videoTrack = composition.addMutableTrack(withMediaType: .video,
                                                     preferredTrackID: kCMPersistentTrackID_Invalid)
        if let track = videoAsset.tracks(withMediaType: .video).first {
            do {
                try videoTrack?.insertTimeRange(.init(start: .zero, duration: videoAsset.duration),
                                                of: track,
                                                at: .zero)
            } catch {
                Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.player)
            }
        }

        // Audio

        var audioAsset = videoAsset

        if let audio = audio, let audioURL = URL(string: audio) {
            audioAsset = AVURLAsset(url: audioURL)
        }

        let audioTrack = composition.addMutableTrack(withMediaType: .audio,
                                                     preferredTrackID: kCMPersistentTrackID_Invalid)

        if let track = audioAsset.tracks(withMediaType: .audio).first {
            do {
                try audioTrack?.insertTimeRange(.init(start: .zero, duration: videoAsset.duration),
                                                of: track,
                                                at: .zero)
            } catch {
                Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.player)
            }
        }

        // Subtitles

        var subAsset = videoAsset

        if let subtitles = subtitles, let subtitlesURL = URL(string: subtitles) {
            subAsset = AVURLAsset(url: subtitlesURL)
        }

        let subTrack = composition.addMutableTrack(withMediaType: .text,
                                                   preferredTrackID: kCMPersistentTrackID_Invalid)

        if let track = subAsset.tracks(withMediaType: .text).first {
            do {
                try subTrack?.insertTimeRange(.init(start: .zero, duration: videoAsset.duration),
                                              of: track,
                                              at: .zero)
            } catch {
                Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.player)
            }
        }

        return AVPlayerItem(asset: composition)
    }

}
