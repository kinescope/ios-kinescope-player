//
//  KinescopeAsset.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//

public struct KinescopeAsset: Codable {
    public let id: String
    public let videoId: String
    public let originalName: String
    public let fileSize: Int?
    public let quality: String
    public let resolution: String
    public let createdAt: String?
    public let updatedAt: String?
    public let url: String
}
