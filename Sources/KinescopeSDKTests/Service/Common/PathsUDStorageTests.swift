import XCTest
@testable import KinescopeSDK

//swiftlint:disable all
final class PathsUDStorageTests: XCTestCase {

    // MARK: - Tests

    func testWriteRead() {

        // given

        let storage = PathsUDStorage(suffix: "mock")
        let urls = ["id1": "url1", "id2": "url2", "id3": "url3"]
        for url in urls {
            storage.save(relativeUrl: url.value, id: url.key)
        }

        // when

        let ids = storage.fetchIds()
        let url2 = storage.readUrl(by: "id2")

        // then

        XCTAssertEqual(Set(urls.keys), Set(ids))
        XCTAssertEqual(urls["id2"], url2)
    }

    func testDelete() {

        // given

        let storage = PathsUDStorage(suffix: "mock")
        let urls = ["id1": "url1", "id2": "url2", "id3": "url3"]
        for url in urls {
            storage.save(relativeUrl: url.value, id: url.key)
        }

        // when

        let deletedUrl = storage.deleteUrl(by: "id2")
        let ids = storage.fetchIds()
        let croppedKeys = ["id1", "id3"]

        // then

        XCTAssertEqual(urls["id2"], deletedUrl)
        XCTAssertEqual(Set(ids), Set(croppedKeys))
    }

}
//swiftlint:enable all
