import XCTest
@testable import KinescopeSDK

final class TransportTests: XCTestCase {

    // MARK: - Nested

    struct MockVideo: Codable, Equatable {
        let id: Int
    }

    final class MockURLSessionDataTask: URLSessionDataTask {
        private let closure: () -> Void

        init(closure: @escaping () -> Void) {
            self.closure = closure
        }

        override func resume() {
            closure()
        }
    }

    final class MockURLSession: URLSession {
        enum Result {
            case success
            case serverError
            case otherError
        }

        private let result: Result

        init(result: Result) {
            self.result = result
        }

        override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {

            switch result {
            case .success:
                let video = MockVideo(id: 1)
                let wrapper = Response(data: video)
                let data = try! JSONEncoder().encode(wrapper)
                let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
                return MockURLSessionDataTask {
                    completionHandler(data, response, nil)
                }
            case .serverError:
                let err = ServerErrorWrapper(error: .init(code: 1, message: "", detail: ""))
                let data = try! JSONEncoder().encode(err)
                let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 400, httpVersion: nil, headerFields: nil)
                return MockURLSessionDataTask {
                    completionHandler(data, response, nil)
                }
            case .otherError:
                return MockURLSessionDataTask {
                    completionHandler(nil, nil, RequestBuilderError.wrongURL)
                }
            }
        }
    }

    // MARK: - Tests

    func testTransportSuccess() {

        // given

        let exp = expectation(description: "testTransportSuccess")
        let transport = Transport(session: MockURLSession(result: .success))
        let expected = MockVideo(id: 1)
        var res: MockVideo?
        var err: Error?

        // when

        transport.perform(request: URLRequest(url: URL(string: "https://example.com")!)) { (response: Result<MockVideo, Error>) in
            switch response {
            case .success(let videos):
                res = videos
            case .failure(let error):
                err = error
            }

            exp.fulfill()
        }

        // then

        wait(for: [exp], timeout: 5.0)

        XCTAssertEqual(res, expected)
        XCTAssertNil(err)
    }

    func testTransportServerError() {

        // given

        let exp = expectation(description: "testTransportServerError")
        let transport = Transport(session: MockURLSession(result: .serverError))
        var res: KinescopeVideo?
        var err: Error?

        // when

        transport.perform(request: URLRequest(url: URL(string: "https://example.com")!)) { (response: Result<KinescopeVideo, Error>) in
            switch response {
            case .success(let videos):
                res = videos
            case .failure(let error):
                err = error
            }

            exp.fulfill()
        }

        // then

        wait(for: [exp], timeout: 5.0)

        XCTAssertTrue(err is ServerError)
        XCTAssertNil(res)
    }

    func testTransportOtherError() {

        // given

        let exp = expectation(description: "testTransportOtherError")
        let transport = Transport(session: MockURLSession(result: .otherError))
        var res: KinescopeVideo?
        var err: Error?

        // when

        transport.perform(request: URLRequest(url: URL(string: "https://example.com")!)) { (response: Result<KinescopeVideo, Error>) in
            switch response {
            case .success(let videos):
                res = videos
            case .failure(let error):
                err = error
            }

            exp.fulfill()
        }

        // then

        wait(for: [exp], timeout: 5.0)

        XCTAssertTrue(err is RequestBuilderError)
        XCTAssertNil(res)
    }
}
