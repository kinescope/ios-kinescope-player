import Foundation

final class Transport {

    // MARK: - Private Properties

    private let session: URLSession

    // MARK: - Lifecycle

    init(session: URLSession = .init(configuration: .default)) {
        self.session = session
    }

    // MARK: - Public Methods

    /// Perform request with composite response
    ///
    /// Example of expected response:
    /// ```
    ///{
    ///  "meta":  //some struct
    ///  "data": // some struct or array
    ///}
    ///```
    func perform<D: Codable, M: Codable>(request: URLRequest, completion: @escaping (Result<MetaResponse<D, M>, Error>) -> Void) {
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            } else if let httpResponse = response as? HTTPURLResponse,
               (200..<300).contains(httpResponse.statusCode),
               let responseData = data {

                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let response = try decoder.decode(MetaResponse<D, M>.self, from: responseData)

                    DispatchQueue.main.async {
                        completion(.success(response))
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

    /// Perform request with simple response
    ///
    /// Example of expected response:
    /// ```
    ///{
    ///  "data": // some struct or array
    ///}
    ///```
    func perform<D: Codable>(request: URLRequest, completion: @escaping (Result<D, Error>) -> Void) {
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            } else if let httpResponse = response as? HTTPURLResponse,
               (200..<300).contains(httpResponse.statusCode),
               let responseData = data {

                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let response = try decoder.decode(Response<D>.self, from: responseData)

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
