import XCTest
@testable import KinescopeSDK

//swiftlint:disable all
final class RequestBuilderTests: XCTestCase {

    // MARK: - Nested

    struct MockRequest: Encodable {
        let id: Int
    }

    // MARK: - Tests

    func testSetAllValues() {

        // given

        let builder = RequestBuilder(path: "https://example.com", method: .get)
        let headers = ["Some": "Header"]
        let token = "1234"
        let params = ["Some": "Param"]
        let body = MockRequest(id: 1)

        // when

        var urlComponents = URLComponents(string: "https://example.com")
        urlComponents!.queryItems = params.map { .init(name: $0.0, value: $0.1) }

        var urlRequest = URLRequest(url:  urlComponents!.url!)
        urlRequest.httpMethod = Method.get.rawValue

        headers.forEach { key, value in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }

        urlRequest.addValue("Bearer 1234", forHTTPHeaderField: "Authorization")

        urlRequest.httpBody = try! JSONEncoder().encode(body)

        let request = try! builder
            .add(token: token)
            .add(headers: headers)
            .add(parameters: params)
            .build(body: body)


        // then

        XCTAssertEqual(urlRequest.httpBody, request.httpBody)
    }

    // MARK: - Set Path

    func testPathSetSuccess() {

        // given

        let path = "https://example.com"
        let builder = RequestBuilder(path: path, method: .get)
        let expected = URLRequest(url: URL(string: path)!)

        // when

        let request = try! builder.build(body: EmptyRequest())

        // then

        XCTAssertEqual(expected, request)

        XCTAssertEqual(expected.url?.absoluteString, request.url?.absoluteString)
        XCTAssertEqual(request.allHTTPHeaderFields, [:])
        XCTAssertNil(request.httpBody)
    }

    func testPathSetFailure() {

        // given

        let pathOne = "https://example.com"
        let pathTwo = "https://example1.com"
        let builder = RequestBuilder(path: pathOne, method: .get)
        let expected = URLRequest(url: URL(string: pathTwo)!)

        // when

        let request = try! builder.build(body: EmptyRequest())

        // then

        XCTAssertNotEqual(expected, request)

        XCTAssertNotEqual(expected.url?.absoluteString, request.url?.absoluteString)
        XCTAssertEqual(request.allHTTPHeaderFields, [:])
        XCTAssertNil(request.httpBody)
    }

    // MARK: - Set Method

    func testMethodSetSuccess() {

        // given

        let getBuilder = RequestBuilder(path: "https://example.com", method: .get)
        var getExpected = URLRequest(url: URL(string: "https://example.com")!)
        let postBuilder = RequestBuilder(path: "https://example.com", method: .post)
        var postExpected = URLRequest(url: URL(string: "https://example.com")!)
        let putBuilder = RequestBuilder(path: "https://example.com", method: .put)
        var putExpected = URLRequest(url: URL(string: "https://example.com")!)
        let patchBuilder = RequestBuilder(path: "https://example.com", method: .patch)
        var patchExpected = URLRequest(url: URL(string: "https://example.com")!)
        let deleteBuilder = RequestBuilder(path: "https://example.com", method: .delete)
        var deleteExpected = URLRequest(url: URL(string: "https://example.com")!)

        // when

        getExpected.httpMethod = "GET"
        let getRequest = try! getBuilder.build(body: EmptyRequest())
        postExpected.httpMethod = "POST"
        let postRequest = try! postBuilder.build(body: EmptyRequest())
        putExpected.httpMethod = "PUT"
        let putRequest = try! putBuilder.build(body: EmptyRequest())
        patchExpected.httpMethod = "PATCH"
        let patchRequest = try! patchBuilder.build(body: EmptyRequest())
        deleteExpected.httpMethod = "DELETE"
        let deleteRequest = try! deleteBuilder.build(body: EmptyRequest())

        // then

        XCTAssertEqual(getExpected, getRequest)
        XCTAssertEqual(postExpected, postRequest)
        XCTAssertEqual(putExpected, putRequest)
        XCTAssertEqual(patchExpected, patchRequest)
        XCTAssertEqual(deleteExpected, deleteRequest)
    }

    func testMethodSetFailure() {

        // given

        let getBuilder = RequestBuilder(path: "https://example.com", method: .get)
        var postExpected = URLRequest(url: URL(string: "https://example.com")!)

        // when

        postExpected.httpMethod = "POST"
        let getRequest = try! getBuilder.build(body: EmptyRequest())

        // then

        XCTAssertNotEqual(postExpected, getRequest)
    }

    // MARK: - Set Headers

    func testSetHeaderSuccess() {

        // given

        let builder = RequestBuilder(path: "https://example.com", method: .get)
        var expected = URLRequest(url: URL(string: "https://example.com")!)

        // when

        expected.addValue("Bearer", forHTTPHeaderField: "Authorization")
        let request = try! builder
            .add(headers: ["Authorization": "Bearer"])
            .build(body: EmptyRequest())

        // then

        XCTAssertEqual(expected, request)

        XCTAssertEqual(expected.url?.absoluteString, request.url?.absoluteString)
        XCTAssertNotEqual(request.allHTTPHeaderFields, [:])
        XCTAssertNil(request.httpBody)
    }

    func testSetHeaderFailure() {

        // given

        let builder = RequestBuilder(path: "https://example.com", method: .get)
        var expected = URLRequest(url: URL(string: "https://example.com")!)

        // when

        expected.addValue("Bearer", forHTTPHeaderField: "Authorization")
        let request = try! builder
            .add(headers: ["Authorization": "Not Bearer"])
            .build(body: EmptyRequest())

        // then

        XCTAssertNotEqual(expected, request)

        XCTAssertEqual(expected.url?.absoluteString, request.url?.absoluteString)
        XCTAssertNotEqual(request.allHTTPHeaderFields, [:])
        XCTAssertNil(request.httpBody)
    }

    func testSetToken() {

        // given

        let builder = RequestBuilder(path: "https://example.com", method: .get)
        var expected = URLRequest(url: URL(string: "https://example.com")!)

        // when

        expected.addValue("Bearer 1234", forHTTPHeaderField: "Authorization")
        let request = try! builder
            .add(token: "1234")
            .build(body: EmptyRequest())

        // then

        XCTAssertEqual(expected.url?.absoluteString, request.url?.absoluteString)
        XCTAssertNotEqual(request.allHTTPHeaderFields, [:])
        XCTAssertNil(request.httpBody)
    }

    func testSetTokenAndOtherHeaders() {

        // given

        let tokenFirstBuilder = RequestBuilder(path: "https://example.com", method: .get)
        let tokenLastBuilder = RequestBuilder(path: "https://example.com", method: .get)
        var expected = URLRequest(url: URL(string: "https://example.com")!)

        // when

        expected.addValue("Bearer 1234", forHTTPHeaderField: "Authorization")
        expected.addValue("Header", forHTTPHeaderField: "Some")

        let tokenFirstRequest = try! tokenFirstBuilder
            .add(token: "1234")
            .add(headers: ["Some": "Header"])
            .build(body: EmptyRequest())

        let tokenLastRequest = try! tokenLastBuilder
            .add(headers: ["Some": "Header"])
            .add(token: "1234")
            .build(body: EmptyRequest())

        // then

        XCTAssertEqual(expected.url?.absoluteString, tokenFirstRequest.url?.absoluteString)
        XCTAssertEqual(expected.url?.absoluteString, tokenLastRequest.url?.absoluteString)
        XCTAssertNotEqual(tokenFirstRequest.allHTTPHeaderFields, [:])
        XCTAssertNil(tokenFirstRequest.httpBody)
    }

    // MARK: - Set Parameters

    func testSetParametersSuccess() {

        // given

        let builder = RequestBuilder(path: "https://example.com", method: .get)
        var components = URLComponents(string: "https://example.com")

        // when

        components?.queryItems = [.init(name: "Name", value: "Value")]
        let expected = URLRequest(url: components!.url!)
        let request = try! builder
            .add(parameters: ["Name": "Value"])
            .build(body: EmptyRequest())

        // then

        XCTAssertEqual(expected, request)

        XCTAssertEqual(expected.url?.absoluteString, request.url?.absoluteString)
        XCTAssertEqual(request.allHTTPHeaderFields, [:])
        XCTAssertNil(request.httpBody)
    }

    func testSetParametersFailures() {

        // given

        let builder = RequestBuilder(path: "https://example.com", method: .get)
        var components = URLComponents(string: "https://example.com")

        // when

        components?.queryItems = [.init(name: "Value", value: "Name")]
        let expected = URLRequest(url: components!.url!)
        let request = try! builder
            .add(parameters: ["Name": "Value"])
            .build(body: EmptyRequest())

        // then

        XCTAssertNotEqual(expected, request)

        XCTAssertNotEqual(expected.url?.absoluteString, request.url?.absoluteString)
        XCTAssertEqual(request.allHTTPHeaderFields, [:])
        XCTAssertNil(request.httpBody)
    }

    // MARK: - Set Body

    func testSetBodySuccess() {

        // given

        let builder = RequestBuilder(path: "https://example.com", method: .get)
        var expected = URLRequest(url: URL(string: "https://example.com")!)

        // when

        expected.httpBody = try! JSONEncoder().encode(MockRequest(id: 1))
        let request = try! builder
            .build(body: MockRequest(id: 1))

        // then

        XCTAssertEqual(expected.httpBody, request.httpBody)

        XCTAssertEqual(expected.url?.absoluteString, request.url?.absoluteString)
        XCTAssertEqual(request.allHTTPHeaderFields, [:])
        XCTAssertNotNil(request.httpBody)
    }

    func testSetBodyFailures() {

        // given

        let builder = RequestBuilder(path: "https://example.com", method: .get)
        var expected = URLRequest(url: URL(string: "https://example.com")!)

        // when

        expected.httpBody = Data()
        let request = try! builder
            .build(body: MockRequest(id: 1))

        // then

        XCTAssertNotEqual(expected.httpBody, request.httpBody)

        XCTAssertEqual(expected.url?.absoluteString, request.url?.absoluteString)
        XCTAssertEqual(request.allHTTPHeaderFields, [:])
        XCTAssertNotNil(request.httpBody)
    }
}
//swiftlint:enable all

