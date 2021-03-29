public final class KinescopeLogger: KinescopeLogging {

    // MARK: - Properties

    private var types: [KinescopeLoggingType]

    // MARK: - KinescopeLogging

    public init(types: [KinescopeLoggingType]) {
        self.types = types
    }

    public func log(message: String, type: KinescopeLoggingType) {
        log(msg: message, type: type)
    }

    public func log(error: Error, type: KinescopeLoggingType) {
        log(msg: error.localizedDescription, type: type)
    }

    // MARK: - Private Methods

    private func log(msg: String, type: KinescopeLoggingType) {
        #if DEBUG

        guard
            type.part(of: types)
        else {
            print("\(types) does not contains selected type – \(type)")
            return
        }

        print("\(type): \(msg)")

        #endif
    }
}
