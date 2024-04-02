@testable import KinescopeSDK

final class LoggerMock: KinescopeLogging {
    
    public var printValue = ""

    func log(message: String, level: KinescopeLoggingLevel) {
        printValue = "\(level): \(message)"
    }

    func log(error: (any Error)?, level: any KinescopeSDK.KinescopeLoggingLevel) {
        guard let error else {
            return
        }
        printValue = "\(level): \(error.localizedDescription)"
    }
}
