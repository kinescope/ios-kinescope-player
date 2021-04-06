//
//  DescriptionCell.swift
//  KinescopeSDK
//
//  Created by Никита Гагаринов on 06.04.2021.
//

import UIKit

final class DescriptionCell: UITableViewCell {

    // MARK: - Nested

    struct Model {
        let title: String
        let value: NSAttributedString
        let config: KinescopeSideMenuItemConfiguration
    }

    // MARK: - Properties

    private weak var titleLabel: UILabel?
    private weak var valueLabel: UILabel?
    private var model: Model?

    // MARK: - Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupInitialState()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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

    // MARK: - Public Methods

    func configure(with model: Model) {
        self.model = model
        titleLabel?.text = model.title
        valueLabel?.attributedText = model.value.string
            .attributedStringWithAssetIconIfNeeded(attributes: [
                .font: model.config.titleFont,
                .foregroundColor: model.config.titleColor
            ])
    }
}

// MARK: - Private

private extension DescriptionCell {

    func setupInitialState() {
        selectionStyle = .none
        backgroundColor = .clear
        setupLayout()
    }

    func setupLayout() {
        let titleLabel = UILabel()
        let valueLabel = UILabel()

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        addSubview(valueLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8.0),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.0),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24.0),
//            titleLabel.trailingAnchor.constraint(equalTo: iconView.leadingAnchor, constant: -4.0),
//
//            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
//            iconView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0)
        ])

        self.titleLabel = titleLabel
    }

}
