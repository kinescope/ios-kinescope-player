//
//  SideMenuBar.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 02.04.2021.
//
// swiftlint:disable implicitly_unwrapped_optional

import UIKit

final class SideMenuBar: UIView {

    struct Model {
        let title: String
        let isRoot: Bool
    }

    // MARK: - Views

    private weak var backButton: UIButton!
    private weak var titleView: UILabel!
    private weak var closeButton: UIButton!

    // MARK: - Properties

    private let config: KinescopeSideMenuBarConfiguration
    private let model: Model

    // MARK: - Init

    init(config: KinescopeSideMenuBarConfiguration, model: Model) {
        self.config = config
        self.model = model
        super.init(frame: .zero)
        setupInitialState()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        .init(width: .greatestFiniteMagnitude, height: config.preferedHeight)
    }

}

// MARK: - Private

private extension SideMenuBar {

    func setupInitialState() {

        configureTitle()
        configureCloseButton()

        titleView.translatesAutoresizingMaskIntoConstraints = false

        if model.isRoot {
            NSLayoutConstraint.activate([
                titleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                titleView.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -4),
                titleView.centerYAnchor.constraint(equalTo: centerYAnchor),
                closeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
                closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
            ])
        } else {
            configureBackButton()

            NSLayoutConstraint.activate([
                backButton.centerYAnchor.constraint(equalTo: centerYAnchor),
                backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                titleView.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 4),
                titleView.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -8),
                titleView.centerYAnchor.constraint(equalTo: centerYAnchor),
                closeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
                closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
            ])
        }
    }

    func configureTitle() {
        let label = UILabel()
        label.font = config.titleFont
        label.textColor = config.titleColor

        addSubview(label)

        self.titleView = label
    }

    func configureCloseButton() {
        let button = UIButton()
        button.setImage(.image(named: "close"), for: .normal)

        addSubview(button)
        button.squareSize(with: config.iconSize)

        self.closeButton = button
    }

    func configureBackButton() {
        let button = UIButton()
        button.setImage(.image(named: "back"), for: .normal)

        addSubview(button)
        button.squareSize(with: config.iconSize)

        self.backButton = button
    }

}
