/// Interface for logging type
public protocol KinescopeLoggingLevel {
    /// Checks that element is part of array
    /// - Parameter array: array of elements
    func part(of array: [KinescopeLoggingLevel]) -> Bool
}

/// Interface for logging
public protocol KinescopeLogging {

    /// Log message
    /// - Parameters:
    ///   - message: string message
    ///   - type: type of logging
    func log(message: String, level: KinescopeLoggingLevel)

    /// Log error
    /// - Parameters:
    ///   - error: error type
    ///   - type: type of logging
    func log(error: Error?, level: KinescopeLoggingLevel)
}
