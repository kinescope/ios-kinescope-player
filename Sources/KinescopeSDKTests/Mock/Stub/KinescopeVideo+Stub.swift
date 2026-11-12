//
//  KinescopeVideo+Stub.swift
//  KinescopeSDKTests
//
//  Created by Никита Коробейников on 29.03.2021.
//

@testable import KinescopeSDK

extension KinescopeVideo {
    
    static func stub(id: String = "", hlsLink: String = "", projectId: String = "", folderId: String? = nil) -> KinescopeVideo {
        .init(id: id,
              workspaceId: nil,
              projectId: projectId,
              folderId: folderId,
              type: .vod,
              title: "",
              description: "",
              status: "",
              progress: 0,
              duration: 0,
              qualityMap: [],
              chapters: .init(items: []),
              poster: .init(url: ""),
              attachments: [],
              subtitles: [],
              hlsLink: hlsLink,
              dashLink: "",
              live: nil,
              analytic: nil,
              drm: nil)
    }

}
