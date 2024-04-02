//
//  KinescopeViewo+Manifest.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 20.02.2024.
//

#if SWIFT_PACKAGE
import M3U8Parser
#else
import M3U8Kit
#endif

extension KinescopeVideo {

    var manifest: M3U8PlaylistModel? {
        guard let url = URL(string: hlsLink) else {
            return nil
        }
        return try? M3U8PlaylistModel(url: url)
    }

    var firstResolution: MediaResoulution? {
        manifest?.masterPlaylist?.xStreamList?.firstStreamInf()?.resolution
    }

}
