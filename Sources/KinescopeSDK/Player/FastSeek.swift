import Foundation

enum FastSeek {
    /// Seconds to move on each fast forward / backward action.
    static let step: TimeInterval = 10
    /// Taps within this interval after previous fast seek continue the series.
    static let streakWindow: TimeInterval = 1.5
}
