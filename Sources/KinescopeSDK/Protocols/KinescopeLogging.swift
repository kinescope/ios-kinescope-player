/// Interface for logging type
public protocol KinescopeLoggingType {
    /// Checks that element is part of array
    /// - Parameter array: array of elements
    func part(of array: [KinescopeLoggingType]) -> Bool
}

/// Interface for logging
public protocol KinescopeLogging {

    /// - Parameter types: types of logging
    init(types: [KinescopeLoggingType])

    /// Log message
    /// - Parameters:
    ///   - message: string message
    ///   - type: type of logging
    func log(message: String, type: KinescopeLoggingType)

    /// Log error
    /// - Parameters:
    ///   - error: error type
    ///   - type: type of logging
    func log(error: Error, type: KinescopeLoggingType)
}
