//
//  DisclosureCell.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 05.04.2021.
//
// swiftlint:disable implicitly_unwrapped_optional

import UIKit

final class DisclosureCell: UITableViewCell {

    struct Model {
        let title: String
        let value: NSAttributedString?
        let config: KinescopeSideMenuItemConfiguration
    }

    // MARK: - Views

    private weak var titleLabel: UILabel!
    private weak var valueLabel: UILabel!
    private weak var iconView: UIImageView!
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

    // MARK: - Methods

    func configure(with model: Model) {
        self.model = model
        setupAppearance(with: model.config)

        titleLabel.text = model.title
        valueLabel.attributedText = model.value
    }

}

// MARK: - Private

private extension DisclosureCell {

    func setupInitialState() {
        selectionStyle = .none
        backgroundColor = .clear

        setupLayout()

    }

    func setupLayout() {

        let titleLabel = UILabel()
        let valueLabel = UILabel()
        let iconView = UIImageView(image: .image(named: "forward"))

        addSubviews(titleLabel, valueLabel, iconView)

        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            valueLabel.trailingAnchor.constraint(equalTo: iconView.leadingAnchor, constant: -16),
            iconView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        self.titleLabel = titleLabel
        self.valueLabel = valueLabel
        self.iconView = iconView

    }

    func setupAppearance(with config: KinescopeSideMenuItemConfiguration) {
        titleLabel.font = config.titleFont
        titleLabel.textColor = config.titleColor

        valueLabel.font = config.valueFont
        valueLabel.textColor = config.valueColor
    }

}
