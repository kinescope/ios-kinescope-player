import Foundation

final class Transport {

    // MARK: - Private Properties

    private let session: URLSession
    private let completionQueue: DispatchQueue

    // MARK: - Lifecycle

    init(session: URLSession = .init(configuration: .default), completionQueue: DispatchQueue = .main) {
        self.session = session
        self.completionQueue = completionQueue
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
        session.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                self?.completionQueue.async {
                    completion(.failure(error))
                }
            } else if let httpResponse = response as? HTTPURLResponse,
               (200..<300).contains(httpResponse.statusCode),
               let responseData = data {

                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let response = try decoder.decode(MetaResponse<D, M>.self, from: responseData)

                    self?.completionQueue.async {
                        completion(.success(response))
                    }
                } catch let error {
                    Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.network)
                    self?.completionQueue.async {
                        completion(.failure(error))
                    }
                }
            } else if let responseData = data {
                do {
                    let error = try JSONDecoder().decode(ServerErrorWrapper.self, from: responseData)

                    self?.completionQueue.async {
                        completion(.failure(error.error))
                    }
                } catch let error {
                    self?.completionQueue.async {
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
        session.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                self?.completionQueue.async {
                    completion(.failure(error))
                }
            } else if let httpResponse = response as? HTTPURLResponse,
               (200..<300).contains(httpResponse.statusCode),
               let responseData = data {

                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let response = try decoder.decode(Response<D>.self, from: responseData)

                    self?.completionQueue.async {
                        completion(.success(response.data))
                    }
                } catch let error {
                    self?.completionQueue.async {
                        completion(.failure(error))
                    }
                }
            } else if let responseData = data {
                do {
                    let error = try JSONDecoder().decode(ServerErrorWrapper.self, from: responseData)

                    self?.completionQueue.async {
                        completion(.failure(error.error))
                    }
                } catch let error {
                    self?.completionQueue.async {
                        completion(.failure(error))
                    }
                }
            }
        }.resume()
    }
    
    /// Perform request with raw data response
    func performRaw(request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        session.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                self?.completionQueue.async {
                    completion(.failure(error))
                }
            } else if let httpResponse = response as? HTTPURLResponse,
               (200..<300).contains(httpResponse.statusCode),
               let responseData = data {

                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase

                    self?.completionQueue.async {
                        completion(.success(responseData))
                    }
                } catch let error {
                    self?.completionQueue.async {
                        completion(.failure(error))
                    }
                }
            }
        }.resume()
    }

    /// Perform fetch request with json response
    ///
    /// Example of expected response:
    /// ```
    ///{
    ///  // some struct or array
    ///}
    ///```
    func performFetch<D: Codable>(request: URLRequest, completion: @escaping (Result<D, Error>) -> Void) {
        session.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                self?.completionQueue.async {
                    completion(.failure(error))
                }
            } else if let httpResponse = response as? HTTPURLResponse,
               (200..<300).contains(httpResponse.statusCode),
               let responseData = data {

                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let response = try decoder.decode(D.self, from: responseData)

                    self?.completionQueue.async {
                        completion(.success(response))
                    }
                } catch let error {
                    self?.completionQueue.async {
                        completion(.failure(error))
                    }
                }
            } else if let responseData = data {
                do {
                    let error = try JSONDecoder().decode(ServerErrorWrapper.self, from: responseData)

                    self?.completionQueue.async {
                        completion(.failure(error.error))
                    }
                } catch let error {
                    self?.completionQueue.async {
                        completion(.failure(error))
                    }
                }
            }
        }.resume()
    }

}
