/// Inner logger proxy. Supports logging levels setup and handling
final class KinescopeLogger: KinescopeLogging {

    // MARK: - Properties

    private let logger: KinescopeLogging
    private let levels: [KinescopeLoggingLevel]

    // MARK: - Lifecycle

    public init(logger: KinescopeLogging, levels: [KinescopeLoggingLevel]) {
        self.logger = logger
        self.levels = levels
    }

    // MARK: - KinescopeLogging

    public func log(message: String, level: KinescopeLoggingLevel) {
        handle(level: level) { [weak self] in
            self?.logger.log(message: message, level: level)
        }
    }

    public func log(error: Error, level: KinescopeLoggingLevel) {
        handle(level: level) { [weak self] in
            self?.logger.log(error: error, level: level)
        }
    }

    // MARK: - Private Methods

    private func handle(level: KinescopeLoggingLevel, completion: () -> Void) {
        #if DEBUG

        guard
            level.part(of: levels)
        else {
            return
        }

        completion()

        #endif
    }
}
