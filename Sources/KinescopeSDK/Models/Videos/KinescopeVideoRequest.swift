public struct KinescopeVideosRequest: Encodable {

    // MARK: - Constants

    public var page: Int
    public let perPage: Int
    public let order: String?

    // MARK: - Lifecycle

    public init(page: Int, perPage: Int, order: String?) {
        self.page = page
        self.perPage = perPage
        self.order = order
    }

    // MARK: - Public Methods

    public mutating func next() -> KinescopeVideosRequest {
        page += perPage
        return self
    }
}
