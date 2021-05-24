/// Asset(of video) model
public struct KinescopeVideoAsset: Codable {
    public let id: String
    public let videoId: String
    public let originalName: String
    public let fileSize: Int
    public let filetype: String
    public let quality: String
    public let resolution: String
    public let createdAt: String
    public let updatedAt: String?
    public let url: String
}
