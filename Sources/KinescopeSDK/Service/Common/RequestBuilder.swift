import Foundation

enum RequestBuilderError: Error {
    case wrongPath
    case wrongURL
}

final class RequestBuilder {

    // MARK: - Private Properties

    private let path: String
    private let method: Method
    private var headers: [String: String]?
    private var parameters: [String: String]?

    // MARK: - Lifecycle

    init(path: String, method: Method) {
        self.path = path
        self.method = method
    }

    // MARK: - Public Methods

    func add(headers: [String: String]) -> RequestBuilder {
        if self.headers != nil {
            headers.forEach { key, value in
                self.headers?[key] = value
            }
        } else {
            self.headers = headers
        }
        return self
    }

    func add(token: String) -> RequestBuilder {
        if self.headers != nil {
            self.headers?["Authorization"] = "Bearer \(token)"
        } else {
            self.headers = ["Authorization": "Bearer \(token)"]
        }
        return self
    }

    func add(parameters: [String: String]) -> RequestBuilder {
        self.parameters = parameters
        return self
    }

    func build<B: Encodable>(body: B) throws -> URLRequest {
        guard
            var urlComponents = URLComponents(string: path)
        else {
            throw RequestBuilderError.wrongPath
        }

        if let parameters = parameters {
            urlComponents.queryItems = parameters.map { .init(name: $0.0, value: $0.1) }
        }

        guard
            let url = urlComponents.url
        else {
            throw RequestBuilderError.wrongURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue

        if let headers = headers {
            headers.forEach { key, value in
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
        }

        if !(body is EmptyRequest) {
            urlRequest.httpBody = try JSONEncoder().encode(body)
        }

        return urlRequest
    }
}
