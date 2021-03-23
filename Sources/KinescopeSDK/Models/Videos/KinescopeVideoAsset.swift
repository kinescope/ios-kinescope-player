public struct KinescopeVideoAsset: Codable {

    // MARK: - CodingKey

    enum Key: String, CodingKey {
        case id
        case videoId = "video_id"
        case originalName = "original_name"
        case fileSize = "file_size"
        case filetype
        case quality
        case resolution
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case url
    }

    // MARK: - Constants

    let id: String
    let videoId: String
    let originalName: String
    let fileSize: Int
    let filetype: String
    let quality: String
    let resolution: String
    let createdAt: String
    let updatedAt: String?
    let url: String

    // MARK: - Lifecycle

    public init(id: String,
                videoId: String,
                originalName: String,
                fileSize: Int,
                filetype: String,
                quality: String,
                resolution: String,
                createdAt: String,
                updatedAt: String?,
                url: String) {
        self.id = id
        self.videoId = videoId
        self.originalName = originalName
        self.fileSize = fileSize
        self.filetype = filetype
        self.quality = quality
        self.resolution = resolution
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.url = url
    }

    // MARK: - Codable

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)

        self.id = try container.decode(String.self, forKey: .id)
        self.videoId = try container.decode(String.self, forKey: .videoId)
        self.originalName = try container.decode(String.self, forKey: .originalName)
        self.fileSize = try container.decode(Int.self, forKey: .fileSize)
        self.filetype = try container.decode(String.self, forKey: .filetype)
        self.quality = try container.decode(String.self, forKey: .quality)
        self.resolution = try container.decode(String.self, forKey: .resolution)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        self.url = try container.decode(String.self, forKey: .url)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)

        try container.encode(id, forKey: .id)
        try container.encode(videoId, forKey: .videoId)
        try container.encode(originalName, forKey: .originalName)
        try container.encode(fileSize, forKey: .fileSize)
        try container.encode(filetype, forKey: .filetype)
        try container.encode(quality, forKey: .quality)
        try container.encode(resolution, forKey: .resolution)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
        try container.encode(url, forKey: .url)
    }
}

// MARK: - Equatable

extension KinescopeVideoAsset: Equatable {
    public static func == (lhs: KinescopeVideoAsset, rhs: KinescopeVideoAsset) -> Bool {
        return lhs.id == rhs.id
    }
}
