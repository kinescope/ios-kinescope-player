struct ServerErrorWrapper: Codable {
    let error: ServerError
}

struct ServerError: Codable, Error {
    let code: Int
    let message: String
    let detail: String?
}
