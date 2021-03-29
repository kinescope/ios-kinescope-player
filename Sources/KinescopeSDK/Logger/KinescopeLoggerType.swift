public enum KinescopeLoggerType: KinescopeLoggingType, Equatable, CaseIterable {
    /// Network logs
    case network
    /// Player logs
    case player

    // MARK: - KinescopeLoggingType

    public func part(of array: [KinescopeLoggingType]) -> Bool {
        guard
            let array = array as? [KinescopeLoggerType]
        else {
            return false
        }

        return array.contains(self)
    }
}
