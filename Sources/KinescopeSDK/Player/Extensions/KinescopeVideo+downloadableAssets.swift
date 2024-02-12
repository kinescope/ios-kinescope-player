//
//  KinescopeVideo+downloadableAssets.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 14.04.2021.
//

import AVFoundation

extension KinescopeVideo {

    var downloadableAssets: [KinescopeVideoAsset] {
        return assets?.filter { isDownloadableFormat(filetype: $0.filetype) } ?? []
    }

    private func isDownloadableFormat(filetype: String) -> Bool {
        let formats = ["mp4"]
        return formats.contains(filetype)
    }

}
