//
//  KinescopeVideoQuality+AVPlayerItem.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 29.03.2021.
//

import AVFoundation

extension KinescopeVideoQuality {

    func makeItem(with dataProtectionHandler: DataProtectionHandler?) -> AVPlayerItem? {
        switch self {
        case .auto(let hlsLink):
            return makeAutoItem(from: hlsLink, with: dataProtectionHandler)
        case .downloaded(let url):
            return makeDownloadedItem(from: url)
        default:
            return nil
        }
    }

}

// MARK: - Private

fileprivate extension KinescopeVideoQuality {

    func makeAutoItem(from hlsLink: String, with dataProtectionHandler: DataProtectionHandler?) -> AVPlayerItem? {
        guard let url = URL(string: hlsLink) else {
            return nil
        }

        let asset = AVURLAsset(url: url)
        
#if !targetEnvironment(simulator)
        dataProtectionHandler?.bind(with: asset)
#endif
        return AVPlayerItem(asset: asset)
    }

    func makeDownloadedItem(from url: URL) -> AVPlayerItem? {
        return AVPlayerItem(url: url)
    }

    @available(*, deprecated, message: "Changing of playerItem is not required. Switching between qualities is handling in HLS stream.")
    func makeExactItem(from asset: KinescopeVideoAssetLink) -> AVPlayerItem? {
        guard let url = URL(string: asset.link) else {
            return nil
        }

        return AVPlayerItem(url: url)
    }

    @available(*, deprecated, message: "Changing of playerItem is not required. Switching between qualities is handling in HLS stream.")
    func makeExactItem(from asset: KinescopeVideoAssetLink,
                       subtitles: KinescopeVideoSubtitle) -> AVPlayerItem? {
        guard let url = URL(string: asset.link)
        else {
            return nil
        }

        guard
            let subtitleURL = URL(string: subtitles.url)
        else {
            return AVPlayerItem(url: url)
        }

        let composition = AVMutableComposition()

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
        } else {
            return AVPlayerItem(url: url)
        }

        let audioTrack = composition.addMutableTrack(withMediaType: .audio,
                                                     preferredTrackID: kCMPersistentTrackID_Invalid)

        if let track = videoAsset.tracks(withMediaType: .audio).first {
            do {
                try audioTrack?.insertTimeRange(.init(start: .zero, duration: videoAsset.duration),
                                                of: track,
                                                at: .zero)
            } catch {
                Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.player)
            }
        } else {
            return AVPlayerItem(url: url)
        }

        let subAsset = AVURLAsset(url: subtitleURL)

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
