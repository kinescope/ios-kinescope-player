/// Request info with sort order and requested page chunk
public struct KinescopeVideosRequest: Encodable {

    // MARK: - Constants

    /// Requested page index
    ///
    /// Starts from `1`
    public var page: Int

    /// Count of videos per page
    ///
    /// By default equal to 5
    public let perPage: Int

    /// Sort order of videos.
    ///
    /// For example: created_at.desc,title.asc
    public let order: String?

    // MARK: - Lifecycle

    public init(page: Int, perPage: Int = 5, order: String? = nil) {
        self.page = page
        self.perPage = perPage
        self.order = order
    }

    // MARK: - Public Methods

    /// Increase page by one
    public mutating func next() -> KinescopeVideosRequest {
        page += 1
        return self
    }
}
