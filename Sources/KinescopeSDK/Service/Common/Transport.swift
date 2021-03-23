import Foundation

final class Transport {

    // MARK: - Private Properties

    private let session: URLSession

    // MARK: - Lifecycle

    init(session: URLSession = .init(configuration: .default)) {
        self.session = session
    }

    // MARK: - Public Methods

    func perform<R: Codable>(request: URLRequest, completion: @escaping (Result<R, Error>) -> Void) {
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            } else if let httpResponse = response as? HTTPURLResponse,
               (200..<300).contains(httpResponse.statusCode),
               let responseData = data {

                do {
                    let response = try JSONDecoder().decode(Response<R>.self, from: responseData)

                    DispatchQueue.main.async {
                        completion(.success(response.data))
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            } else if let responseData = data {
                do {
                    let error = try JSONDecoder().decode(ServerErrorWrapper.self, from: responseData)

                    DispatchQueue.main.async {
                        completion(.failure(error.error))
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }.resume()
    }
}
