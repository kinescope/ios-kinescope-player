public struct KinescopeVideosRequest: Encodable {

    // MARK: - CodingKey

    enum Key: String, CodingKey {
        case page
        case perPage = "per_page"
        case order
    }

    // MARK: - Constants

    var page: Int
    let perPage: Int
    let order: String?

    // MARK: - Lifecycle

    public init(page: Int, perPage: Int, order: String?) {
        self.page = page
        self.perPage = perPage
        self.order = order
    }

    // MARK: - Encodable

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)

        try container.encode(page, forKey: .page)
        try container.encode(perPage, forKey: .perPage)
        try container.encodeIfPresent(order, forKey: .order)
    }

    // MARK: - Public Methods

    public mutating func next() -> KinescopeVideosRequest {
        page += perPage
        return self
    }
}
