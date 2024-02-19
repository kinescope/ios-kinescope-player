//
//  KinescopeVideo+downloadableAssets.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 14.04.2021.
//

import AVFoundation

extension KinescopeVideo {

    var downloadableAssets: [KinescopeVideoAsset] {
        return qualityMap ?? []
    }

}
