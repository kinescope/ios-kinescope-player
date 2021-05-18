//
//  AssetServiceTest.swift
//  KinescopeSDKTests
//
//  Created by Artemii Shabanov on 12.04.2021.
//

import XCTest
@testable import KinescopeSDK

//swiftlint:disable all
final class AssetServiceTests: XCTestCase {

    // MARK: - Setup

    var assetService: AssetNetworkService?
    var assetServiceDelegate: AssetServiceDelegateMock?
    var assetLinksServiceMock: AssetLinksServiceMock?

    let mockUrlString = "https://example.com"
    let mockUrl = URL(string: "https://example.com")!

    override func setUp() {
        super.setUp()
        let assetLinksServiceMock = AssetLinksServiceMock()
        self.assetLinksServiceMock = assetLinksServiceMock
        self.assetService = AssetNetworkService()
        self.assetServiceDelegate = AssetServiceDelegateMock()
        self.assetService?.delegate = assetServiceDelegate
    }

    override func tearDown() {
        super.tearDown()
        assetService = nil
        assetServiceDelegate = nil
        assetLinksServiceMock = nil
    }

    // MARK: - Tests

    func testEnqueueDownloadSuccess() {

        // given
        let exp = expectation(description: "testEnqueueDownloadSuccess")
        let assetId = "1"
        var err: Error?

        assetServiceDelegate?.completionHandler = { _, _, error in
            err = error
            exp.fulfill()
        }
        assetService?.setSession(MockAVAssetDownloadURLSession(delegate: assetService))

        // when
        assetLinksServiceMock?.linkMock = ["1": .success(.init(link: mockUrlString))]
        assetService?.enqueueDownload(assetId: assetId, url: mockUrl)

        // then
        wait(for: [exp], timeout: 2.5)

        XCTAssertNil(err)
    }

    func testEnqueueDownloadError() {

        // given
        let exp = expectation(description: "testEnqueueDownloadError")
        let assetId = "1"
        var err: Error?

        assetServiceDelegate?.completionHandler = { _, _, error in
            err = error
            exp.fulfill()
        }
        let session = MockAVAssetDownloadURLSession(delegate: assetService)
        session.nextResult = .error
        assetService?.setSession(session)

        // when
        assetLinksServiceMock?.linkMock = ["1": .success(.init(link: mockUrlString))]
        assetService?.enqueueDownload(assetId: assetId, url: mockUrl)

        // then
        wait(for: [exp], timeout: 2.5)

        XCTAssertNotNil(err)
    }

    func testDequeueDownload() {

        // given
        let exp = expectation(description: "testDequeueDownload")
        let assetId = "1"
        var isTaskFinished = false
        let session = MockAVAssetDownloadURLSession(delegate: assetService)

        assetServiceDelegate?.completionHandler = { _, _, _ in
            isTaskFinished = true
        }
        assetService?.setSession(session)

        // when
        assetLinksServiceMock?.linkMock = ["1": .success(.init(link: mockUrlString))]
        assetService?.enqueueDownload(assetId: assetId, url: mockUrl)
        assetService?.dequeueDownload(assetId: assetId)

        // Fullfill after 1.5 second and check that completion handler didn't work
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            exp.fulfill()
        }

        // then
        wait(for: [exp], timeout: 3.0)

        XCTAssertFalse(isTaskFinished)
    }

    func testPauseAndResumeDownload() {

        // given
        let pauseExp = expectation(description: "testPauseDownload")
        let resumeExp = expectation(description: "testResumeDownloadAfterPause")
        let assetId = "1"
        var isTaskFinished = false
        let session = MockAVAssetDownloadURLSession(delegate: assetService)

        assetServiceDelegate?.completionHandler = { _, _, _ in
            isTaskFinished = true
            resumeExp.fulfill()
        }
        assetService?.setSession(session)

        // when
        assetLinksServiceMock?.linkMock = ["1": .success(.init(link: mockUrlString))]
        assetService?.enqueueDownload(assetId: assetId, url: mockUrl)
        assetService?.pauseDownload(assetId: assetId)

        // Fullfill pauseExp after 1.5 second and check that task didn't finished
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            pauseExp.fulfill()
            self.assetService?.resumeDownload(assetId: assetId)
        }

        // then
        wait(for: [pauseExp], timeout: 3.0)
        XCTAssertFalse(isTaskFinished)
        wait(for: [resumeExp], timeout: 4.5)
        XCTAssertTrue(isTaskFinished)
    }

    func testRestoreTasks() {

        // given
        let pauseExp = expectation(description: "testPauseAllTasks")
        let resumeExp = expectation(description: "testRestoreAllTasksAfterPause")
        //assetId : isFinished
        var assetIds = ["1" : false, "2" : false, "3": false]
        var isAllTasksFinished = false
        let session = MockAVAssetDownloadURLSession(delegate: assetService)

        assetServiceDelegate?.completionHandler = { assetId, _, _ in
            assetIds[assetId] = true
            if assetIds.allSatisfy( {$0.value == true } ) {
                isAllTasksFinished = true
                resumeExp.fulfill()
            }
        }
        assetService?.setSession(session)

        // when
        assetLinksServiceMock?.linkMock = ["1": .success(.init(link: mockUrlString + "1")),
                                           "2": .success(.init(link: mockUrlString + "2")),
                                           "3": .success(.init(link: mockUrlString + "3"))]
        assetIds.forEach {
            assetService?.enqueueDownload(assetId: $0.key, url: URL(string: mockUrlString + $0.key)!)
        }
        assetIds.forEach {
            assetService?.pauseDownload(assetId: $0.key)
        }

        // Fullfill pauseExp after 2.5 second and check that tasks didn't finished
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            pauseExp.fulfill()
            self.assetService?.restore()
        }

        // then
        wait(for: [pauseExp], timeout: 3.0)
        XCTAssertFalse(isAllTasksFinished)
        wait(for: [resumeExp], timeout: 4.5)
        XCTAssertTrue(isAllTasksFinished)
    }

}
