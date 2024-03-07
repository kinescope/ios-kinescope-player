//
//  KinescopeVideo+downloadableAssets.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 14.04.2021.
//

import AVFoundation

extension KinescopeVideo {

    var downloadableAssets: [KinescopeVideoAsset] {
        return qualityMap?.sorted(by: { $0.height > $1.height }) ?? []
    }

    var hasAssets: Bool {
        !downloadableAssets.isEmpty
    }

    func firstQuality(by name: String) -> KinescopeVideoAsset? {
        downloadableAssets.first(where: { $0.name == name })
    }

}
