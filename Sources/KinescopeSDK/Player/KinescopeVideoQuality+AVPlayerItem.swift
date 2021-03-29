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

}
