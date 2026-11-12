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
    public let dashLink: String?
    public let live: KinescopeStreamMeta?
    public let analytic: KinescopeAnalyticEndpoints?
    public let drm: KinescopeDRMData?

    enum CodingKeys: String, CodingKey {
        case id
        case workspaceId
        case projectId
        case folderId
        case type
        case title
        case description
        case status
        case progress
        case duration
        case qualityMap
        case chapters
        case poster
        case attachments
        case subtitles
        case hlsLink
        case dashLink
        case live
        case analytic = "sdk"
        case drm
    }
}

extension KinescopeVideo {
    /// Live payloads omit fields that VOD always sends. Missing values must not fail the whole video.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        workspaceId = try container.decodeIfPresent(String.self, forKey: .workspaceId)
        projectId = try container.decodeIfPresent(String.self, forKey: .projectId) ?? ""
        folderId = try container.decodeIfPresent(String.self, forKey: .folderId)
        type = try container.decodeIfPresent(KinescopeStreamType.self, forKey: .type)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        status = try container.decodeIfPresent(String.self, forKey: .status)
        progress = try container.decodeIfPresent(Int.self, forKey: .progress)
        duration = try container.decodeIfPresent(Double.self, forKey: .duration) ?? 0
        qualityMap = try? container.decode([KinescopeVideoAsset].self, forKey: .qualityMap)
        chapters = (try? container.decode(KinescopeVideoChapter.self, forKey: .chapters))
            ?? KinescopeVideoChapter(items: nil)
        poster = try? container.decode(KinescopeVideoPoster.self, forKey: .poster)
        attachments = try? container.decode([KinescopeVideoAdditionalMaterial].self, forKey: .attachments)
        subtitles = try? container.decode([KinescopeVideoSubtitle].self, forKey: .subtitles)
        hlsLink = try container.decodeIfPresent(String.self, forKey: .hlsLink) ?? ""
        dashLink = try container.decodeIfPresent(String.self, forKey: .dashLink)
        live = try? container.decode(KinescopeStreamMeta.self, forKey: .live)
        analytic = try? container.decode(KinescopeAnalyticEndpoints.self, forKey: .analytic)
        drm = try? container.decode(KinescopeDRMData.self, forKey: .drm)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(workspaceId, forKey: .workspaceId)
        try container.encode(projectId, forKey: .projectId)
        try container.encodeIfPresent(folderId, forKey: .folderId)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encodeIfPresent(progress, forKey: .progress)
        try container.encode(duration, forKey: .duration)
        try container.encodeIfPresent(qualityMap, forKey: .qualityMap)
        try container.encode(chapters, forKey: .chapters)
        try container.encodeIfPresent(poster, forKey: .poster)
        try container.encodeIfPresent(attachments, forKey: .attachments)
        try container.encodeIfPresent(subtitles, forKey: .subtitles)
        try container.encode(hlsLink, forKey: .hlsLink)
        try container.encodeIfPresent(dashLink, forKey: .dashLink)
        try container.encodeIfPresent(live, forKey: .live)
        try container.encodeIfPresent(analytic, forKey: .analytic)
        try container.encodeIfPresent(drm, forKey: .drm)
    }
}
