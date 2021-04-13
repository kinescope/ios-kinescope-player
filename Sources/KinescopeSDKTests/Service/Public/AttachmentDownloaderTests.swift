//
//  AttachmentDownloaderTests.swift
//  KinescopeSDKTests
//
//  Created by Никита Гагаринов on 09.04.2021.
//

import XCTest
@testable import KinescopeSDK

//swiftlint:disable all
final class AttachmentDownloaderTests: XCTestCase {

    // MARK: - Setup

    var downloader: KinescopeAttachmentDownloadable?
    var fileService: FileServiceMock?
    var delegate: KinescopeAttachmentDownloadableDelegateMock?

    override func setUp() {
        super.setUp()
        let fileService = FileServiceMock()
        self.downloader = AttachmentDownloader(fileService: fileService)
        self.fileService = fileService
        let delegate = KinescopeAttachmentDownloadableDelegateMock()
        self.delegate = delegate
        self.downloader?.add(delegate: delegate)
    }

    override func tearDown() {
        super.tearDown()

        downloader?.clear()
        downloader = nil
    }

    // MARK: - Tests

    func testDelegateConsistency() {

        // given
        fileService?.attachmentStates = [
            "1": .progress(0.5),
            "2": .error(KinescopeDownloadError.notFound),
            "3": .completed
        ]

        // when
        for attachmentId in (fileService?.attachmentStates ?? [:]).keys {
            downloader?.enqueueDownload(attachmentId: attachmentId, url: URL(string: "https://example.com/\(attachmentId)")!)
        }

        // then
        XCTAssertEqual(delegate?.attachments["1"]?.progress, 0.5)
        XCTAssertEqual(delegate?.attachments["2"]?.error, KinescopeDownloadError.notFound)
        XCTAssertNotNil(delegate?.attachments["3"]!.url)
    }

    func testSuccessSavingFileInCache() {

        // given
        let attachmentId =  "1"
        fileService?.attachmentStates[attachmentId] = .completed
        //when
        downloader?.enqueueDownload(attachmentId: attachmentId, url: URL(string: "https://example.com")!)

        let isDownloaded = downloader?.isDownloaded(attachmentId: attachmentId) ?? false
        // Check that delegate got's attachemnt too
        let urlFromDelegate = delegate?.attachments[attachmentId]!.url

        //then
        XCTAssertTrue(isDownloaded)
        XCTAssertNotNil(urlFromDelegate)
    }

    func testGettingAllAttachemntsFromCache() {

        //given
        let attachmentsIds = ["1", "2", "3"]
        attachmentsIds.forEach {
            fileService?.attachmentStates[$0] = .completed
        }

        //when
        attachmentsIds.forEach {
            downloader?.enqueueDownload(attachmentId: $0, url: URL(string: "https://example.com/\($0)")!)
        }

        //then
        var filePaths: [URL] = []
        let attachemntsList = downloader!.downloadedAttachmentsList()

        attachmentsIds.forEach {
            filePaths.append(downloader!.getLocation(of: $0)!)
        }
        let isContainsAll = attachemntsList.allSatisfy(filePaths.contains)

        XCTAssertTrue(isContainsAll)
    }

    func testSuccessDeleteFromCache() {

        //given
        let attachmentId = "1"
        fileService?.attachmentStates[attachmentId] = .completed

        //when
        downloader?.enqueueDownload(attachmentId: attachmentId, url: URL(string: "https://example.com")!)
        let isDeleted = downloader?.delete(attachmentId: attachmentId) ?? false

        //then
        XCTAssertTrue(isDeleted)
    }

    func testFailDeleteFromCache() {

        //given
        let attachmentId = "1"
        fileService?.attachmentStates[attachmentId] = .completed

        //when
        downloader?.enqueueDownload(attachmentId: attachmentId, url: URL(string: "https://example.com")!)
        let isDeleted = downloader?.delete(attachmentId: "2") ?? false

        //then
        XCTAssertFalse(isDeleted)
    }

    func testSuccessClearFromCache() {

        //given
        let attachemntsIds = ["1", "2", "3"]
        attachemntsIds.forEach {
            fileService?.attachmentStates[$0] = .completed
        }

        //when
        attachemntsIds.forEach {
            downloader?.enqueueDownload(attachmentId: $0, url: URL(string: "https://example.com/\($0)")!)
        }
        downloader?.clear()

        // then
        let urls = downloader?.downloadedAttachmentsList()

        XCTAssertEqual(urls, [])
    }

    func testCacheConsistency() {

        //given
        let attachmentId = "1"
        let mockFileData = "mockData"
        fileService?.attachmentStates[attachmentId] = .completed

        //when
        downloader?.enqueueDownload(attachmentId: attachmentId, url: URL(string: "https://example.com/")!)
        let isDownloaded = downloader?.isDownloaded(attachmentId: attachmentId) ?? false

        //then
        XCTAssertTrue(isDownloaded)

        //when
        let attachmentLocation = downloader?.getLocation(of: attachmentId)

        //then
        let fileData = try? String(contentsOf: attachmentLocation!, encoding: .utf8)
        XCTAssertEqual(fileData, mockFileData)

        //when
        let isDeleted = downloader?.delete(attachmentId: attachmentId) ?? false
        let deletedAttachmentLocation = downloader?.getLocation(of: attachmentId)

        //then
        XCTAssertTrue(isDeleted)
        XCTAssertNil(deletedAttachmentLocation)
    }



}
