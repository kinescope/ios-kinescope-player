import Foundation

/// Item of playlist shown in player playlist menu.
public struct KinescopePlaylistItem: Equatable {
    public let id: String
    public let title: String
    public let durationSeconds: TimeInterval?
    public let posterUrl: String?
    public let shareUrl: String?

    public init(id: String,
                title: String,
                durationSeconds: TimeInterval? = nil,
                posterUrl: String? = nil,
                shareUrl: String? = nil) {
        self.id = id
        self.title = title
        self.durationSeconds = durationSeconds
        self.posterUrl = posterUrl
        self.shareUrl = shareUrl
    }
}
