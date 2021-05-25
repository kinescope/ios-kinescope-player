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
        addShadow(to: titleLabel)
        stackView.addArrangedSubview(titleLabel)
    }

    func configureSubtitleLabel() {
        subtitleLabel.font = config.subtitleFont
        subtitleLabel.textColor = config.subtitleColor
        addShadow(to: subtitleLabel)
        stackView.addArrangedSubview(subtitleLabel)
    }

    func addShadow(to label: UILabel) {
        let layer = label.layer
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.64).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
    }

}
