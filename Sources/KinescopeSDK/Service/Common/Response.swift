struct Response<D: Codable>: Codable {
    let data: D
}

struct MetaResponse<D: Codable, M: Codable>: Codable {
    let data: D
    let meta: M
}
