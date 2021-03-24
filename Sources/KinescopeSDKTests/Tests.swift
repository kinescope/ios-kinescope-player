//
//  Tests.swift
//  KinescopeSDKTests
//
//  Created by Никита Коробейников on 20.03.2021.
//

import XCTest
@testable import KinescopeSDK

//swiftlint:disable all
/// Just stub for tests
final class Tests: XCTestCase {

    // MARK: - Properties

    var videosService: VideosService!
    var assetsService: AssetsService!

    // MARK: - XCTestCase

    override func setUp() {
        super.setUp()
        // FIXME: Remove apikey
        videosService = VideosService(transport: .init(), config: .init(apiKey: "q9AJMHcAvQaFSiZpsNUVuE"))
        assetsService = AssetsService(transport: .init(), config: .init(apiKey: "q9AJMHcAvQaFSiZpsNUVuE"))
    }

    override func tearDown() {
        super.tearDown()
        videosService = nil
        assetsService = nil
    }

    // MARK: - Tests

    func stubTest() {
        Kinescope.shared.setConfig(.init(apiKey: "stub"))
    }

    // MARK: - Videos service tests

    func testGetAllVideos() {

        // given

        let firstExp = expectation(description: "testGetAllVideos.1")
        let secondExp = expectation(description: "testGetAllVideos.2")
        var request = KinescopeVideosRequest(page: 1, perPage: 1, order: nil)
        var res: [KinescopeVideo]?
        var err: Error?

        // when

        videosService.getAll(request: request) { result in
            switch result {
            case .success(let videos):
                res = videos
            case .failure(let error):
                err = error
            }

            firstExp.fulfill()
        }

        wait(for: [firstExp], timeout: 5.0)

        XCTAssertTrue(res?.count == 1)

        videosService.getAll(request: request.next()) { result in
            switch result {
            case .success(let videos):
                res?.append(contentsOf: videos)
            case .failure(let error):
                err = error
            }

            secondExp.fulfill()
        }

        wait(for: [secondExp], timeout: 5.0)

        XCTAssertTrue(res?.count == 2)

        // then

        XCTAssertNotNil(res)
        XCTAssertNil(err)
    }

    func testGetVideo() {

        // given

        let exp = expectation(description: "testGetVideo")
        var res: KinescopeVideo?
        var err: Error?

        // when

        // FIXME: Remove id
        videosService.getVideo(by: "kzNymAg8mku4MoxvMEMmCX") { result in
            switch result {
            case .success(let videos):
                res = videos
            case .failure(let error):
                err = error
            }

            exp.fulfill()
        }

        // then

        wait(for: [exp], timeout: 5.0)

        XCTAssertNotNil(res)
        XCTAssertNil(err)
    }

    // MARK: - Assets service tests

    func testGetLink() {

        // given

        let exp = expectation(description: "testGetLink")
        var res: KinescopeVideoAssetLink?
        var err: Error?

        // when

        // FIXME: Remove id
        assetsService.getAssetLink(by: "gokYVoXeNXBD2cJgJaYAJD") { result in
            switch result {
            case .success(let link):
                res = link
            case .failure(let error):
                err = error
            }

            exp.fulfill()
        }

        // then

        wait(for: [exp], timeout: 5.0)

        XCTAssertNotNil(res)
        XCTAssertFalse(res!.link.isEmpty)
        XCTAssertNil(err)
    }
}
//swiftlint:enable all
