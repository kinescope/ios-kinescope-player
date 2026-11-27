import XCTest
@testable import KinescopeSDK

final class SessionExternalIdTests: XCTestCase {

    func testExternalIdIsSentInTheSession() {
        let session = SessionAnalyticDataFactory()
        session.set(externalId: "user-42")

        XCTAssertEqual(session.provide()?.externalID, "user-42")
    }

    func testExternalIdIsTrimmed() {
        let session = SessionAnalyticDataFactory()
        session.set(externalId: "  user-42 \n")

        XCTAssertEqual(session.provide()?.externalID, "user-42")
    }

    func testNilOrBlankExternalIdSendsNothing() {
        let session = SessionAnalyticDataFactory()

        session.set(externalId: nil)
        XCTAssertEqual(session.provide()?.externalID, "")

        session.set(externalId: "   ")
        XCTAssertEqual(session.provide()?.externalID, "")
        XCTAssertNil(session.externalId)
    }

    func testExternalIdDoesNotChangeOtherSessionFields() {
        let session = SessionAnalyticDataFactory()
        let without = session.provide()
        session.set(externalId: "user-42")
        let with = session.provide()

        XCTAssertEqual(without?.id, with?.id)
        XCTAssertEqual(without?.viewID, with?.viewID)
        XCTAssertEqual(without?.watchedDuration, with?.watchedDuration)
        XCTAssertFalse(with?.id.isEmpty ?? true)
    }

    func testPlayerConfigPassesExternalIdToAnalytics() {
        // Mocks: the convenience initializer needs `Kinescope.shared.setConfig`, which a unit test does not call.
        let dependencies = KinescopeVideoPlayerDependenciesMock(drmFactoryStub: .init(),
                                                                inspectorMock: KinescopeInspectableMock(),
                                                                assetDownloaderMock: KinescopeAssetDownloadableMock(),
                                                                strategyMock: PlayingStrategyMock(),
                                                                attachmentDownloaderMock: KinescopeAttachmentDownloaderMock())
        let player = KinescopeVideoPlayer(config: .init(videoId: "test", externalId: "user-7"),
                                          dependencies: dependencies)

        XCTAssertEqual(player.externalId, "user-7")

        player.externalId = "user-8"
        XCTAssertEqual(player.externalId, "user-8")
    }
}
