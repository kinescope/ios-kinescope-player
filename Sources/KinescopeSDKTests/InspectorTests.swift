//
//  InspectorTests.swift
//  KinescopeSDKTests
//
//  Created by Никита Коробейников on 23.03.2021.
//

import XCTest
@testable import KinescopeSDK

final class InspectorTests: XCTestCase {

    var videoService: VideosService?
    var inspector: KinescopeInspectable?

    override func setUp() {
        super.setUp()

//        inspector = Inspector(videosService: videoService)
    }

    override func tearDown() {
        super.tearDown()

        inspector = nil
    }

    func testListSuccessPassingToCallback() {

        // TODO: - add mocked API layer

        var successCalled: Bool = false
        var errorCatched: KinescopeInspectError?

        inspector?.list(onSuccess: { _ in
            successCalled = true
        }, onError: { error in
            errorCatched = error
        })

        XCTAssertTrue(successCalled)
        XCTAssertNil(errorCatched)
    }

    func testListError404MappedToNotFound() {

        // TODO: - add mocked API layer

        var successCalled: Bool = false
        var errorCatched: KinescopeInspectError?

        inspector?.list(onSuccess: { _ in
            successCalled = true
        }, onError: { error in
            errorCatched = error
        })

        XCTAssertFalse(successCalled)
        XCTAssertEqual(errorCatched, KinescopeInspectError.notFound)
    }

    func testListError403MappedToDenied() {

        // TODO: - add mocked API layer

        var successCalled: Bool = false
        var errorCatched: KinescopeInspectError?

        inspector?.list(onSuccess: { _ in
            successCalled = true
        }, onError: { error in
            errorCatched = error
        })

        XCTAssertFalse(successCalled)
        XCTAssertEqual(errorCatched, KinescopeInspectError.denied)
    }

    func testListError500MappedToUnknown() {

        // TODO: - add mocked API layer

        var successCalled: Bool = false
        var errorCatched: KinescopeInspectError?

        inspector?.list(onSuccess: { _ in
            successCalled = true
        }, onError: { error in
            errorCatched = error
        })

        XCTAssertFalse(successCalled)
        XCTAssertEqual(errorCatched, KinescopeInspectError.unknown(KinescopeInspectError.notFound))
    }

    func testListErrorNegativeMappedToNetwork() {

        var successCalled: Bool = false
        var errorCatched: KinescopeInspectError?

        inspector?.list(onSuccess: { _ in
            successCalled = true
        }, onError: { error in
            errorCatched = error
        })

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
