//
//  KinescopeVideo.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//
import GoSwiftyM3U8

public struct KinescopeVideo: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case projectId
        case version
        case title
        case description
        case status
        case progress
        case duration
        case assets
        case chapters
        case poster
        case additionalMaterials
        case subtitles
        case hlsLink
    }

    public let id: String
    public let projectId: String
    public let version: Int
    public let title: String
    public let description: String
    public let status: String
    public let progress: Int
    public let duration: Double
    public let assets: [KinescopeVideoAsset]
    public let chapters: KinescopeVideoChapter
    public let poster: KinescopeVideoPoster?
    public let additionalMaterials: [KinescopeVideoAdditionalMaterial]
    public let subtitles: [KinescopeVideoSubtitle]
    public let hlsLink: String
    public var manifest: Playlist? = nil
}
