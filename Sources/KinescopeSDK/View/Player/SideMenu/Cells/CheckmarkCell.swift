import UIKit

/// Side menu cell with chackmark
final class CheckmarkCell: UITableViewCell {

    // MARK: - Nested

    struct Model {
        let title: NSAttributedString
        let selected: Bool
        let config: KinescopeSideMenuItemConfiguration
    }

    // MARK: - Properties

    private weak var titleLabel: UILabel?
    private weak var iconView: UIImageView?
    private var model: Model?

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupInitialState()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UITableViewCell

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        guard
            let highlightedColor = model?.config.highlightedColor
        else {
            return
        }

        let color = highlighted ? highlightedColor : .clear

        UIView.animate(withDuration: 0.3) {
            self.backgroundColor = color
        }
    }

    // MARK: - Internal Methods

    func configure(with model: Model) {
        self.model = model

        iconView?.isHidden = !model.selected

        titleLabel?.attributedText = model.title.string
            .attributedStringWithAssetIconIfNeeded(attributes: [
                .font: model.config.titleFont,
                .foregroundColor: model.config.titleColor
            ])
    }

}

// MARK: - Private

private extension CheckmarkCell {

    func setupInitialState() {
        selectionStyle = .none
        backgroundColor = .clear
        setupLayout()
    }

    func setupLayout() {
        let titleLabel = UILabel()
        let iconView = UIImageView(image: .image(named: "checkmark"))

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        addSubview(iconView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8.0),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.0),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24.0),
            titleLabel.trailingAnchor.constraint(equalTo: iconView.leadingAnchor, constant: -4.0),

            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])

        self.titleLabel = titleLabel
        self.iconView = iconView
    }

}
