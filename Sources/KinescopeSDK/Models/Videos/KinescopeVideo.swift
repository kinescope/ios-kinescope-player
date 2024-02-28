//
//  KinescopeVideo.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//

public struct KinescopeVideo: Codable {
    public let id: String
    public let workspaceId: String?
    public let projectId: String
    public let folderId: String?
    public let type: KinescopeStreamType?
    public let title: String
    public let description: String
    public let status: String?
    public let progress: Int?
    public let duration: Double
    public let qualityMap: [KinescopeVideoAsset]?
    public let chapters: KinescopeVideoChapter
    public let poster: KinescopeVideoPoster?
    public let attachments: [KinescopeVideoAdditionalMaterial]?
    public let subtitles: [KinescopeVideoSubtitle]?
    public let hlsLink: String
    public let dash_link: String?
}
