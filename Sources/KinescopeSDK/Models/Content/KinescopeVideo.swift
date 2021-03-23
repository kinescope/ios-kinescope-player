//
//  KinescopeVideo.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//

public struct KinescopeVideo: Codable {
    public let id: String
    public let projectId: String
    public let folderId: String?
    public let title: String?
    public let assets: [KinescopeAsset]
    public let poster: String?
    public let materialsEnabled: Bool
    public let subtitlesEnabled: Bool
    public let createdAt: String?
    public let updatedAt: String?
    public let playLink: String?
    public let embedLink: String?
    public let hlsLink: String?
}
