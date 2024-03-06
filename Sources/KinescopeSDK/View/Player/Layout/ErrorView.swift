//
//  ErrorView.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 06.03.2024.
//

import UIKit

protocol ErrorViewInput {
    func display(error: Error)
}

protocol ErrorViewOutput: AnyObject {
    func didRerty()
}

final class ErrorView: UIView {

    // MARK: - Properties

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let retryButton = UIButton()

    private let config: KinescopeErrorConfiguration

    private weak var delegate: ErrorViewOutput?

    // MARK: - Lifecycle

    init(config: KinescopeErrorConfiguration, delegate: ErrorViewOutput? = nil) {
        self.config = config
        self.delegate = delegate
        super.init(frame: .zero)
        self.setupInitialState()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - ErrorViewInput

extension ErrorView {

    func display(error: Error?) {
        subtitleLabel.text = error?.localizedDescription
        superview?.bringSubviewToFront(self)
        showAnimated()
    }
}

// MARK: - Private

private extension ErrorView {
    
    func setupInitialState() {
        setupAppearence()
        setupLayout()

        titleLabel.text = L10n.Player.error
        retryButton.setTitle(L10n.Player.refresh, for: .normal)
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
    }

    func setupAppearence() {
        backgroundColor = config.backgroundColor
        iconView.image = config.image

        titleLabel.font = config.titleFont
        titleLabel.textColor = config.titleColor
        
        subtitleLabel.font = config.subtitleFont
        subtitleLabel.textColor = config.subtitleColor
        subtitleLabel.numberOfLines = 0
        subtitleLabel.lineBreakMode = .byWordWrapping
        subtitleLabel.textAlignment = .center

        retryButton.titleLabel?.font = config.buttonTtileFont
        retryButton.backgroundColor = config.buttonColor
        retryButton.layer.cornerRadius = 6
        retryButton.layer.masksToBounds = true
        retryButton.contentEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 16)
        retryButton.contentVerticalAlignment = .center
        retryButton.contentHorizontalAlignment = .center
    }

    func setupLayout() {
        addSubviews(iconView, titleLabel, subtitleLabel, retryButton)

        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -16),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            subtitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            retryButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),
            retryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            retryButton.heightAnchor.constraint(equalToConstant: 32),
            iconView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -8),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

}

// MARK: - Actions

private extension ErrorView {
    @objc
    func retryButtonTapped() {
        hideAnimated()
        delegate?.didRerty()
    }
}
