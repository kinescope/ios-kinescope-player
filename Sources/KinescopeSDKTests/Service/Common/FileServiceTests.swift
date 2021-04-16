//
//  FileServiceTests.swift
//  KinescopeSDKTests
//
//  Created by Никита Гагаринов on 09.04.2021.
//

import XCTest
@testable import KinescopeSDK

//swiftlint:disable all
final class FileServiceTests: XCTestCase {

    // MARK: - Setup

    var fileService: FileNetworkService?
    var fileServiceDelegate: FileServiceDelegateMock?

    override func setUp() {
        super.setUp()
        fileService = FileNetworkService(downloadIdentifier: "attachments")
        fileServiceDelegate = FileServiceDelegateMock()
        fileService?.delegate = fileServiceDelegate
    }

    override func tearDown() {
        super.tearDown()
        fileService = nil
        fileServiceDelegate = nil
    }

    // MARK: - Tests

    func testEnqueueDownloadSuccess() {

        // given
        let exp = expectation(description: "testEnqueueDownloadSuccess")
        let fileId = "1"
        var downloadedFileLocation: URL?
        var err: Error?

        fileServiceDelegate?.completionHandler = { _, location, error in
            downloadedFileLocation = location
            err = error
            exp.fulfill()
        }
        fileService?.setSession(MockDownloadURLSession(delegate: fileService))

        // when
        fileService?.enqueueDownload(fileId: fileId, url: URL(string: "https://example.com")!)

        // then
        wait(for: [exp], timeout: 2.0)

        XCTAssertEqual(downloadedFileLocation, URL(string: "https://example.com"))
        XCTAssertNil(err)
    }

    func testEnqueueDownloadError() {

        // given
        let exp = expectation(description: "testEnqueueDownloadSuccess")
        let fileId = "1"
        var downloadedFileLocation: URL?
        var err: Error?

        fileServiceDelegate?.completionHandler = { _, location, error in
            downloadedFileLocation = location
            err = error
            exp.fulfill()
        }
        let session = MockDownloadURLSession(delegate: fileService)
        session.nextResult = .error
        fileService?.setSession(session)

        // when
        fileService?.enqueueDownload(fileId: fileId, url: URL(string: "https://example.com")!)

        // then
        wait(for: [exp], timeout: 2.0)

        XCTAssertNil(downloadedFileLocation)
        XCTAssertNotNil(err)
    }

    func testDequeueDownload() {

        // given
        let exp = expectation(description: "testDequeueDownload")
        let fileId = "1"
        var isTaskFinished = false
        let session = MockDownloadURLSession(delegate: fileService)

        fileServiceDelegate?.completionHandler = { _, _, _ in
            isTaskFinished = true
        }
        fileService?.setSession(session)

        // when
        fileService?.enqueueDownload(fileId: fileId, url: URL(string: "https://example.com")!)
        fileService?.dequeueDownload(fileId: fileId)

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
        let fileId = "1"
        var isTaskFinished = false
        let session = MockDownloadURLSession(delegate: fileService)

        fileServiceDelegate?.completionHandler = { _, _, _ in
            isTaskFinished = true
            resumeExp.fulfill()
        }
        fileService?.setSession(session)

        // when
        fileService?.enqueueDownload(fileId: fileId, url: URL(string: "https://example.com")!)
        fileService?.pauseDownload(fileId: fileId)

        // Fullfill pauseExp after 1.5 second and check that task didn't finished
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            pauseExp.fulfill()
            self.fileService?.resumeDownload(fileId: fileId)
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
        //fileId : isFinished
        var fileIds = ["1" : false, "2" : false, "3": false]
        var isAllTasksFinished = false
        let session = MockDownloadURLSession(delegate: fileService)

        fileServiceDelegate?.completionHandler = { fileId, _, _ in
            fileIds[fileId] = true
            if fileIds.allSatisfy( {$0.value == true } ) {
                isAllTasksFinished = true
                resumeExp.fulfill()
            }
        }
        fileService?.setSession(session)

        // when
        fileIds.forEach {
            fileService?.enqueueDownload(fileId: $0.key, url: URL(string: "https://example.com/\($0.key)")!)
        }
        fileIds.forEach {
            fileService?.pauseDownload(fileId: $0.key)
        }

        // Fullfill pauseExp after 2.5 second and check that tasks didn't finished
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            pauseExp.fulfill()
            self.fileService?.restore()
        }

        // then
        wait(for: [pauseExp], timeout: 3.0)
        XCTAssertFalse(isAllTasksFinished)
        wait(for: [resumeExp], timeout: 5.0)
        XCTAssertTrue(isAllTasksFinished)
    }

}
