import XCTest
@testable import KinescopeSDK

//swiftlint:disable all
final class LoggerTests: XCTestCase {

    // MARK: - Nested

    enum MockError: Error {
        case err
    }

    enum MockKinescope {
        static let shared = MockManager()
    }

    final class MockLogger: KinescopeLogging {
        public var printValue = ""
        private var types: [KinescopeLoggingType]

        init(types: [KinescopeLoggingType]) {
            self.types = types
        }

        func log(message: String, type: KinescopeLoggingType) {
            log(msg: message, type: type)
        }

        func log(error: Error, type: KinescopeLoggingType) {
            log(msg: error.localizedDescription, type: type)
        }

        private func log(msg: String, type: KinescopeLoggingType) {
            guard
                type.part(of: types)
            else {
                printValue = "\(types) does not contains selected type – \(type)"
                return
            }

            printValue = "\(type): \(msg)"
        }
    }

    final class MockManager: KinescopeServicesProvider, KinescopeConfigurable {

        // MARK: - KinescopeServicesProvider

        var downloader: KinescopeDownloadable!
        var inspector: KinescopeInspectable!
        var logger: KinescopeLogging!

        // MARK: - KinescopeConfigurable

        func setConfig(_ config: KinescopeConfig) {
        }

        func set(logingTypes: [KinescopeLoggingType]) {
            self.logger = MockLogger(types: logingTypes)
        }
    }

    // MARK: - XCTestCase



    // MARK: - Tests

    func testEmptyLoggingTypes() {

        // given

        let expectedSuccess = "\([]) does not contains selected type – \(KinescopeLoggerType.player)"
        let expectedFailure = "\(KinescopeLoggerType.player): Message"
        MockKinescope.shared.set(logingTypes: [])

        // when

        MockKinescope.shared.logger.log(message: "Message", type: KinescopeLoggerType.player)

        // then

        XCTAssertEqual(expectedSuccess, (MockKinescope.shared.logger as! MockLogger).printValue)
        XCTAssertNotEqual(expectedFailure, (MockKinescope.shared.logger as! MockLogger).printValue)
    }

    func testAllTypes() {

        let expectedNetwork = "\(KinescopeLoggerType.network): Network"
        let expectedPlayer = "\(KinescopeLoggerType.player): Player"
        MockKinescope.shared.set(logingTypes: KinescopeLoggerType.allCases)

        MockKinescope.shared.logger.log(message: "Network", type: KinescopeLoggerType.network)
        XCTAssertEqual(expectedNetwork, (MockKinescope.shared.logger as! MockLogger).printValue)

        MockKinescope.shared.logger.log(message: "Player", type: KinescopeLoggerType.player)
        XCTAssertEqual(expectedPlayer, (MockKinescope.shared.logger as! MockLogger).printValue)

    }

    func testOneTypeSuccess() {

        // given

        let expected = "\(KinescopeLoggerType.player): Message"
        MockKinescope.shared.set(logingTypes: [KinescopeLoggerType.player])

        // when

        MockKinescope.shared.logger.log(message: "Message", type: KinescopeLoggerType.player)

        // then

        XCTAssertEqual(expected, (MockKinescope.shared.logger as! MockLogger).printValue)
    }

    func testOneTypeFailure() {

        // given

        let expected = "\([KinescopeLoggerType.player]) does not contains selected type – \(KinescopeLoggerType.network)"
        MockKinescope.shared.set(logingTypes: [KinescopeLoggerType.player])

        // when

        MockKinescope.shared.logger.log(message: "Message", type: KinescopeLoggerType.network)

        // then

        XCTAssertEqual(expected, (MockKinescope.shared.logger as! MockLogger).printValue)
    }

    func testLogError() {

        // given

        let expected = "\(KinescopeLoggerType.player): The operation couldn’t be completed. (KinescopeSDKTests.LoggerTests.MockError error 0.)"
        MockKinescope.shared.set(logingTypes: [KinescopeLoggerType.player])

        // when

        MockKinescope.shared.logger.log(error: MockError.err, type: KinescopeLoggerType.player)

        // then

        XCTAssertEqual(expected, (MockKinescope.shared.logger as! MockLogger).printValue)
    }
}
//swiftlint:enable all
