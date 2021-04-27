//
//  ErrorView.swift
//  KinescopeSDK
//
//  Created by Никита Гагаринов on 27.04.2021.
//

import UIKit

protocol ErrorViewDelegate: class {
    func didRefreshTap()
}

final class ErrorView: UIView {

    // MARK: - Private Properties

    private let config: KinescopeErrorViewConfiguration
    private weak var delegate: ErrorViewDelegate?
    private let stackView = UIStackView()

    // MARK: - Init

    init(config: KinescopeErrorViewConfiguration, delegate: ErrorViewDelegate?) {
        self.config = config
        self.delegate = delegate
        super.init(frame: .zero)
        configureAppearence()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Private Methods

private extension ErrorView {

    func configureAppearence() {
        backgroundColor = config.backgroundColor
        configureStackView()
        fillStackView()
    }

    func configureStackView() {
        stackView.sizeToFit()
        addSubview(stackView)
        centerChild(view: stackView)
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 0
    }

    func fillStackView() {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = config.image
        stackView.addArrangedSubview(imageView)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = L10n.Player.error
        titleLabel.font = config.titleFont
        titleLabel.textColor = config.titleColor
        titleLabel.sizeToFit()
        stackView.addArrangedSubview(titleLabel)

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = L10n.Player.tryAgain
        subtitleLabel.font = config.subtitleFont
        subtitleLabel.textColor = config.subtitleColor
        subtitleLabel.sizeToFit()
        stackView.addArrangedSubview(subtitleLabel)

        let refreshButton = UIButton(type: .system)
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        refreshButton.titleLabel?.font = config.refreshTitleFont
        refreshButton.tintColor = config.refreshTitleColor
        refreshButton.setTitle(L10n.Player.refresh, for: .normal)
        refreshButton.layer.cornerRadius = config.refreshCornerRadius
        refreshButton.layer.borderWidth = config.refreshBorderWidth
        refreshButton.layer.borderColor = config.refreshBorderColor.cgColor
        refreshButton.addTarget(self, action: #selector(refreshButtonAction), for: .touchUpInside)
        stackView.addArrangedSubview(refreshButton)

        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 32),
            imageView.widthAnchor.constraint(equalToConstant: 32),
            refreshButton.widthAnchor.constraint(equalToConstant: 81),
            refreshButton.heightAnchor.constraint(equalToConstant: 32),
            stackView.widthAnchor.constraint(equalToConstant: max(titleLabel.frame.width, subtitleLabel.frame.width))
        ])

        if #available(iOS 11.0, *) {
            stackView.setCustomSpacing(8, after: imageView)
            stackView.setCustomSpacing(16, after: subtitleLabel)
        } else {
            stackView.addCustomSpacing(after: imageView, value: 8)
            stackView.addCustomSpacing(after: subtitleLabel, value: 16)
        }

    }

    @objc
    private func refreshButtonAction() {
        delegate?.didRefreshTap()
    }

}

// MARK: - UIStackView

private extension UIStackView {

    func addCustomSpacing(after view: UIView, value: CGFloat)  {
        guard let arrangedSubviewIndex = arrangedSubviews.firstIndex(of: view) else {
            return
        }

        let separatorView = UIView(frame: .zero)
        separatorView.translatesAutoresizingMaskIntoConstraints = false

        switch axis {
        case .horizontal:
            separatorView.widthAnchor.constraint(equalToConstant: value).isActive = true
        case .vertical:
            separatorView.heightAnchor.constraint(equalToConstant: value).isActive = true
        }

        insertArrangedSubview(separatorView, at: arrangedSubviewIndex + 1)
    }

}


