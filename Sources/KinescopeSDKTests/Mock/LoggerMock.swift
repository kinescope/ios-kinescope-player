@testable import KinescopeSDK

final class LoggerMock: KinescopeLogging {
    public var printValue = ""

    func log(message: String, level: KinescopeLoggingLevel) {
        printValue = "\(level): \(message)"
    }

    func log(error: Error, level: KinescopeLoggingLevel) {
        printValue = "\(level): \(error.localizedDescription)"
    }
}
