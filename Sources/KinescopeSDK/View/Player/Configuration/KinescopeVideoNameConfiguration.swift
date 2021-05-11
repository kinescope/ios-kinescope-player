import UIKit

/// Appearence preferences for title and subtitle above video
public struct KinescopeVideoNameConfiguration {

    let titleFont: UIFont
    let titleColor: UIColor
    let subtitleFont: UIFont
    let subtitleColor: UIColor

    /// - Parameters:
    ///   - titleFont: font for top title text
    ///   - titleColor: color for top title text
    ///   - subtitleFont: font for bottom description text
    ///   - subtitleColor: color for bottom description text
    public init(titleFont: UIFont, titleColor: UIColor, subtitleFont: UIFont, subtitleColor: UIColor) {
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.subtitleFont = subtitleFont
        self.subtitleColor = subtitleColor
    }
}

// MARK: - Defaults

public extension KinescopeVideoNameConfiguration {
    static let `default`: KinescopeVideoNameConfiguration = .init(
        titleFont: .systemFont(ofSize: 14.0, weight: .medium),
        titleColor: UIColor.white,
        subtitleFont: .systemFont(ofSize: 12.0),
        subtitleColor: UIColor.white
    )

}
