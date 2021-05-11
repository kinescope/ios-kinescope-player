//
//  KinescopeVideoQuality+AVPlayerItem.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 29.03.2021.
//

import AVFoundation

extension KinescopeVideoQuality {

    var item: AVPlayerItem? {
        return makeItem()
    }

}

// MARK: - Private

fileprivate extension KinescopeVideoQuality {

    func makeItem() -> AVPlayerItem? {
        guard let url = URL(string: link) else {
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
