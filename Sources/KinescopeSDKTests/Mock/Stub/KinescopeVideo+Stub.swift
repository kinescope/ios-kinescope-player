//
//  KinescopeVideo+Stub.swift
//  KinescopeSDKTests
//
//  Created by Никита Коробейников on 29.03.2021.
//

@testable import KinescopeSDK

extension KinescopeVideo {

    static func stub(id: String = "") -> KinescopeVideo {
        .init(id: id,
              projectId: "",
              version: 0,
              title: "",
              description: "",
              status: "",
              progress: 0,
              duration: 0,
              assets: [],
              chapters: .init(items: []),
              poster: .init(id: "", original: "", md: "", sm: "", xs: ""),
              additionalMaterials: [],
              subtitles: [],
              hlsLink: "")

    }

}
