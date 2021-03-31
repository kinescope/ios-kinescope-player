import XCTest
@testable import KinescopeSDK

//swiftlint:disable all
final class LoggerTests: XCTestCase {

    // MARK: - Properties

    var logger: LoggerMock!

    // MARK: - XCTestCase

    override func setUp() {
        super.setUp()
        logger = LoggerMock()
    }

    override func tearDown() {
        super.tearDown()
        logger = nil
    }

    // MARK: - Tests

    func testEmptyLoggingTypes() {

        // given

        let expectedSuccess = ""
        let expectedFailure = "\(KinescopeLoggerLevel.player): Message"
        Kinescope.shared.set(logger: logger, levels: [])

        // when

        Kinescope.shared.logger.log(message: "Message", level: KinescopeLoggerLevel.player)

        // then

        XCTAssertEqual(expectedSuccess, logger.printValue)
        XCTAssertNotEqual(expectedFailure, logger.printValue)
    }

    func testAllTypes() {

        let expectedNetwork = "\(KinescopeLoggerLevel.network): Network"
        let expectedPlayer = "\(KinescopeLoggerLevel.player): Player"
        Kinescope.shared.set(logger: logger, levels: KinescopeLoggerLevel.allCases)

        Kinescope.shared.logger.log(message: "Network", level: KinescopeLoggerLevel.network)
        XCTAssertEqual(expectedNetwork, logger.printValue)

        Kinescope.shared.logger.log(message: "Player", level: KinescopeLoggerLevel.player)
        XCTAssertEqual(expectedPlayer, logger.printValue)

    }

    func testOneTypeSuccess() {

        // given

        let expected = "\(KinescopeLoggerLevel.player): Message"
        Kinescope.shared.set(logger: logger, levels: [KinescopeLoggerLevel.player])

        // when

        Kinescope.shared.logger.log(message: "Message", level: KinescopeLoggerLevel.player)

        // then

        XCTAssertEqual(expected, logger.printValue)
    }

    func testOneTypeFailure() {

        // given

        let expected = ""
        Kinescope.shared.set(logger: logger, levels: [KinescopeLoggerLevel.player])

        // when

        Kinescope.shared.logger.log(message: "Message", level: KinescopeLoggerLevel.network)

        // then

        XCTAssertEqual(expected, logger.printValue)
    }

    func testLogError() {

        // given

        let expected = "\(KinescopeLoggerLevel.player): The operation couldn’t be completed. (KinescopeSDKTests.ErrorMock error 0.)"
        Kinescope.shared.set(logger: logger, levels: [KinescopeLoggerLevel.player])

        // when

        Kinescope.shared.logger.log(error: ErrorMock.err, level: KinescopeLoggerLevel.player)

        // then

        XCTAssertEqual(expected, logger.printValue)
    }
}
//swiftlint:enable all
