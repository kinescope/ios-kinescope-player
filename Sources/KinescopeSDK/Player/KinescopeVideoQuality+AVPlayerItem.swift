//
//  KinescopeVideoQuality+AVPlayerItem.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 29.03.2021.
//

import AVFoundation

extension KinescopeVideoQuality {

    var item: AVPlayerItem? {
        switch self {
        case .auto(let hlsLink):
            return makeAutoItem(from: hlsLink)
        case .exact(let asset):
            return makeExactItem(from: asset)
        case .exactWithSubtitles(let asset, let subtitles):
            return makeExactItem(from: asset, subtitles: subtitles)
        }
    }

}

// MARK: - Private

fileprivate extension KinescopeVideoQuality {

    func makeAutoItem(from hlsLink: String) -> AVPlayerItem? {
        guard let url = URL(string: hlsLink) else {
            return nil
        }

        let asset = AVAsset(url: url)
        return AVPlayerItem(asset: asset)
    }

    func makeExactItem(from asset: KinescopeVideoAsset) -> AVPlayerItem? {
        guard let url = URL(string: asset.url) else {
            return nil
        }

        return AVPlayerItem(url: url)
    }

    func makeExactItem(from asset: KinescopeVideoAsset,
                       subtitles: KinescopeVideoSubtitle) -> AVPlayerItem? {
        guard
            let url = URL(string: asset.url)
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
