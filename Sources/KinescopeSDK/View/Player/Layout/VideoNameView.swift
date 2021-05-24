import UIKit

protocol VideoNameInput {

    /// Sets name and description of video
    ///
    /// - parameter title: top text
    /// - parameter description: bottom text
    func set(title: String, subtitle: String)
}

/// Configurable video name view with title and subtitle
final class VideoNameView: UIView {

    // MARK: - Properties

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let config: KinescopeVideoNameConfiguration
    private let stackView = UIStackView()

    // MARK: - Lifecycle

    init(config: KinescopeVideoNameConfiguration) {
        self.config = config
        super.init(frame: .zero)
        setupInitialState()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - VideoNameInput

extension VideoNameView: VideoNameInput {
    func set(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}

// MARK: - Private

private extension VideoNameView {
    func setupInitialState() {
        configureStackView()
        configureTitleLabel()
        configureSubtitleLabel()
    }

    func configureStackView() {
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 4.0
        addSubview(stackView)
        stretch(view: stackView)
    }

    func configureTitleLabel() {
        titleLabel.font = config.titleFont
        titleLabel.numberOfLines = 2
        titleLabel.textColor = config.titleColor
        stackView.addArrangedSubview(titleLabel)
    }

    func configureSubtitleLabel() {
        subtitleLabel.font = config.subtitleFont
        subtitleLabel.textColor = config.subtitleColor
        stackView.addArrangedSubview(subtitleLabel)
    }
}
