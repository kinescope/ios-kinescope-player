/// Default KinescopeLogging implementation. Based on standard output print() method
public final class KinescopeDefaultLogger: KinescopeLogging {

    public init() {}

    // MARK: - KinescopeLogging

    /// Logs simple string message
    /// - Parameters:
    ///   - message: String message
    ///   - level: Loggel level
    public func log(message: String, level: KinescopeLoggingLevel) {
        print("\(level): \(message)")
    }

    /// Logs error
    /// - Parameters:
    ///   - error: Error
    ///   - level: Loggel level
    public func log(error: Error, level: KinescopeLoggingLevel) {
        print("\(level): \(error.localizedDescription)")
    }
}
