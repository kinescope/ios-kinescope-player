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
        titleColor: UIColor.white.withAlphaComponent(0.8),
        subtitleFont: .systemFont(ofSize: 12.0),
        subtitleColor: UIColor.white.withAlphaComponent(0.8)
    )
}

// MARK: - Builder

public class KinescopeVideoNameConfigurationBuilder {
    private var titleFont: UIFont
    private var titleColor: UIColor
    private var subtitleFont: UIFont
    private var subtitleColor: UIColor

    public init(configuration: KinescopeVideoNameConfiguration) {
        self.titleFont = configuration.titleFont
        self.titleColor = configuration.titleColor
        self.subtitleFont = configuration.subtitleFont
        self.subtitleColor = configuration.subtitleColor
    }

    public func setTitleFont(_ titleFont: UIFont) -> Self {
        self.titleFont = titleFont
        return self
    }

    public func setTitleColor(_ titleColor: UIColor) -> Self {
        self.titleColor = titleColor
        return self
    }

    public func setSubtitleFont(_ subtitleFont: UIFont) -> Self {
        self.subtitleFont = subtitleFont
        return self
    }
    
    public func setSubtitleColor(_ subtitleColor: UIColor) -> Self {
        self.subtitleColor = subtitleColor
        return self
    }

    public func build() -> KinescopeVideoNameConfiguration {
        return .init(titleFont: titleFont,
                     titleColor: titleColor,
                     subtitleFont: subtitleFont,
                     subtitleColor: subtitleColor)
    }
}
