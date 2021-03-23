//
//  KinescopeVideo.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//

public struct KinescopeVideo: Codable {

    // MARK: - CodingKey

    enum Key: String, CodingKey {
        case id
        case projectId = "project_id"
        case version
        case status
        case progress
        case duration
        case assets
        case poster
        case subtitlesEnabled = "subtitles_enabled"
        case hlsLink = "hls_link"
    }

    // MARK: - Constants

    let id: String
    let projectId: String
    let version: Int
    let status: String
    let progress: Int
    let duration: Double
    let assets: [KinescopeVideoAsset]
    let poster: KinescopeVideoPoster
    let subtitlesEnabled: Bool
    let hlsLink: String

    // MARK: - Lifecycle

    public init(id: String,
                projectId: String,
                version: Int,
                status: String,
                progress: Int,
                duration: Double,
                assets: [KinescopeVideoAsset],
                poster: KinescopeVideoPoster,
                subtitlesEnabled: Bool,
                hlsLink: String) {
        self.id = id
        self.projectId = projectId
        self.version = version
        self.status = status
        self.progress = progress
        self.duration = duration
        self.assets = assets
        self.poster = poster
        self.subtitlesEnabled = subtitlesEnabled
        self.hlsLink = hlsLink
    }

    // MARK: - Codable

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)

        self.id = try container.decode(String.self, forKey: .id)
        self.projectId = try container.decode(String.self, forKey: .projectId)
        self.version = try container.decode(Int.self, forKey: .version)
        self.status = try container.decode(String.self, forKey: .status)
        self.progress = try container.decode(Int.self, forKey: .progress)
        self.duration = try container.decode(Double.self, forKey: .duration)
        self.assets = try container.decode(Array<KinescopeVideoAsset>.self, forKey: .assets)
        self.poster = try container.decode(KinescopeVideoPoster.self, forKey: .poster)
        self.subtitlesEnabled = try container.decode(Bool.self, forKey: .subtitlesEnabled)
        self.hlsLink = try container.decode(String.self, forKey: .hlsLink)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)

        try container.encode(id, forKey: .id)
        try container.encode(projectId, forKey: .projectId)
        try container.encode(version, forKey: .version)
        try container.encode(status, forKey: .status)
        try container.encode(progress, forKey: .progress)
        try container.encode(duration, forKey: .duration)
        try container.encode(assets, forKey: .assets)
        try container.encode(poster, forKey: .poster)
        try container.encode(subtitlesEnabled, forKey: .subtitlesEnabled)
        try container.encode(hlsLink, forKey: .hlsLink)
    }
}

// MARK: - Equatable

extension KinescopeVideo: Equatable {
    public static func == (lhs: KinescopeVideo, rhs: KinescopeVideo) -> Bool {
        return lhs.id == rhs.id
    }
}
