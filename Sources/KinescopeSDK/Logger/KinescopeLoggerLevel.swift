/// Default logger levels 
public enum KinescopeLoggerLevel: KinescopeLoggingLevel, Equatable, CaseIterable {
    /// Network logs
    case network
    /// Player logs
    case player
    /// Storage logs
    case storage
    /// Analytics logs
    case analytics

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
