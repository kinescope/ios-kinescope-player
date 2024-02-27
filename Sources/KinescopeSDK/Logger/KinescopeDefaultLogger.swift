public final class KinescopeDefaultLogger: KinescopeLogging {

    public init() {}

    // MARK: - KinescopeLogging

    public func log(message: String, level: KinescopeLoggingLevel) {
        debugPrint("📺 \(level): \(message)")
    }

    public func log(error: Error?, level: KinescopeLoggingLevel) {
        debugPrint("📺 \(level): 🚨 \(error?.localizedDescription ?? "unknown error")")
    }
}
