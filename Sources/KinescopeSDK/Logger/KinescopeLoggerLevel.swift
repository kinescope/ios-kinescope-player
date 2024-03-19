public enum KinescopeLoggerLevel: KinescopeLoggingLevel, Equatable, CaseIterable {
    /// Network logs
    case network
    /// DRM protection logs
    case drm
    /// Player logs
    case player
    /// Repeater logs
    case repeater
    /// Player logs
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
