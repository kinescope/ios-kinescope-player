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
        let icon: UIImage?
        let config: KinescopeSideMenuItemConfiguration
    }

    private enum Constants {
        static let inset: CGFloat = 16
        static let leadingIconSize: CGFloat = 20
        static let leadingIconGap: CGFloat = 12
    }

    // MARK: - Views

    private weak var leadingIconView: UIImageView!
    private weak var titleLabel: UILabel!
    private weak var valueLabel: UILabel!
    private weak var iconView: UIImageView!
    private var titleLeading: NSLayoutConstraint!
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
        leadingIconView.image = model.icon
        leadingIconView.isHidden = model.icon == nil
        titleLeading.constant = model.icon == nil
            ? Constants.inset
            : Constants.inset + Constants.leadingIconSize + Constants.leadingIconGap
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

        let leadingIconView = UIImageView()
        let titleLabel = UILabel()
        let valueLabel = UILabel()
        let iconView = UIImageView(image: .image(named: "forward"))

        leadingIconView.contentMode = .scaleAspectFit
        iconView.contentMode = .scaleAspectFit
        valueLabel.textAlignment = .right
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        addSubviews(leadingIconView, titleLabel, valueLabel, iconView)

        let titleLeading = titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.inset)

        NSLayoutConstraint.activate([
            leadingIconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.inset),
            leadingIconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            leadingIconView.widthAnchor.constraint(equalToConstant: Constants.leadingIconSize),
            leadingIconView.heightAnchor.constraint(equalToConstant: Constants.leadingIconSize),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLeading,
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8),
            valueLabel.trailingAnchor.constraint(equalTo: iconView.leadingAnchor, constant: -4),
            iconView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 6),
            iconView.heightAnchor.constraint(equalToConstant: 10)
        ])

        self.leadingIconView = leadingIconView
        self.titleLabel = titleLabel
        self.valueLabel = valueLabel
        self.iconView = iconView
        self.titleLeading = titleLeading

    }

    func setupAppearance(with config: KinescopeSideMenuItemConfiguration) {
        titleLabel.font = config.titleFont
        titleLabel.textColor = config.titleColor

        valueLabel.font = config.valueFont
        valueLabel.textColor = config.valueColor
    }

}
