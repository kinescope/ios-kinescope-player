//
//  InspectorTests.swift
//  KinescopeSDKTests
//
//  Created by Никита Коробейников on 23.03.2021.
//

import XCTest
@testable import KinescopeSDK

final class InspectorTests: XCTestCase {

    var videoService: VideoServiceMock?
    var inspector: KinescopeInspectable?

    override func setUp() {
        super.setUp()

        let videoService = VideoServiceMock()
        self.inspector = Inspector(videosService: videoService)
        self.videoService = videoService
    }

    override func tearDown() {
        super.tearDown()

        inspector = nil
    }

    func testListSuccessPassingToCallback() {

        // given

        videoService?.allVideosMock[1] = .success(.init(data: [KinescopeVideo](),
                                                        meta: .init(pagination: .init(page: 1,
                                                                                      perPage: 5,
                                                                                      total: 0))))

        var successCalled: Bool = false
        var errorCatched: KinescopeInspectError?

        // when

        inspector?.list(onSuccess: { _ in
            successCalled = true
        }, onError: { error in
            errorCatched = error
        })

        // then

        XCTAssertTrue(successCalled)
        XCTAssertNil(errorCatched)
    }

    func testListError404MappedToNotFound() {

        // given

        videoService?.allVideosMock[1] = .failure(ServerError(code: 404, message: "", detail: nil))

        var successCalled: Bool = false
        var errorCatched: KinescopeInspectError?

        // when

        inspector?.list(onSuccess: { _ in
            successCalled = true
        }, onError: { error in
            errorCatched = error
        })

        // then

        XCTAssertFalse(successCalled)
        XCTAssertEqual(errorCatched, KinescopeInspectError.notFound)
    }

    func testListError403MappedToDenied() {

        // given

        videoService?.allVideosMock[1] = .failure(ServerError(code: 403, message: "", detail: nil))

        var successCalled: Bool = false
        var errorCatched: KinescopeInspectError?

        // when

        inspector?.list(onSuccess: { _ in
            successCalled = true
        }, onError: { error in
            errorCatched = error
        })

        // then

        XCTAssertFalse(successCalled)
        XCTAssertEqual(errorCatched, KinescopeInspectError.denied)
    }

    func testListError500MappedToUnknown() {

        // given

        videoService?.allVideosMock[1] = .failure(ServerError(code: 500, message: "", detail: nil))

        var successCalled: Bool = false
        var errorCatched: KinescopeInspectError?

        // when

        inspector?.list(onSuccess: { _ in
            successCalled = true
        }, onError: { error in
            errorCatched = error
        })

        // then

        XCTAssertFalse(successCalled)
        XCTAssertEqual(errorCatched, KinescopeInspectError.unknown(KinescopeInspectError.notFound))
    }

    func testListErrorNegativeMappedToNetwork() {

        // given

        videoService?.allVideosMock[1] = .failure(ServerError(code: -1, message: "", detail: nil))

        var successCalled: Bool = false
        var errorCatched: KinescopeInspectError?

        // when

        inspector?.list(onSuccess: { _ in
            successCalled = true
        }, onError: { error in
            errorCatched = error
        })

        // then

        XCTAssertFalse(successCalled)
        XCTAssertEqual(errorCatched, KinescopeInspectError.network)
    }

}

// MARK: - Helper

extension KinescopeInspectError: Equatable {
    public static func == (lhs: KinescopeInspectError, rhs: KinescopeInspectError) -> Bool {
        switch (lhs, rhs) {
        case (.network, .network):
            return true
        case (.notFound, .notFound):
            return true
        case (.denied, .denied):
            return true
        case (.unknown, .unknown):
            return true
        default:
            return false
        }
    }
}
