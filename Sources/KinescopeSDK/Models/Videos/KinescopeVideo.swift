//
//  KinescopeVideo.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//

public struct KinescopeVideo: Codable {
    public let id: String
    public let projectId: String
    public let version: Int
    public let status: String
    public let progress: Int
    public let duration: Double
    public let assets: [KinescopeVideoAsset]
    public let poster: KinescopeVideoPoster?
    public let subtitlesEnabled: Bool
    public let hlsLink: String
}
