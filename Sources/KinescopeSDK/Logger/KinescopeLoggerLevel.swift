public enum KinescopeLoggerLevel: KinescopeLoggingLevel, Equatable, CaseIterable {
    /// Network logs
    case network
    /// Player logs
    case player
    /// Player logs
    case storage

    // MARK: - KinescopeLoggingType

    public func part(of array: [KinescopeLoggingLevel]) -> Bool {
        guard
            let array = array as? [KinescopeLoggerLevel]
        else {
            return false
        }

        return array.contains(self)
    }
}
