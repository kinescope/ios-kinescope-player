//
//  AnnounceView.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 06.03.2024.
//

import UIKit

protocol AnnounceViewInput {
    func display(startsAt: Date?)
}

final class AnnounceView: UIView {

    // MARK: - Properties

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, h:mm a"
        return dateFormatter
    }()

    private let config: KinescopeAnnounceConfiguration

    // MARK: - Lifecycle

    init(config: KinescopeAnnounceConfiguration) {
        self.config = config
        super.init(frame: .zero)
        self.setupInitialState()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - AnnounceViewInput

extension AnnounceView: AnnounceViewInput {
    func display(startsAt: Date?) {
        if let startsAt {
            subtitleLabel.text = dateFormatter.string(from: startsAt)
        } else {
            subtitleLabel.text = ""
        }
        if isHidden {
            showAnimated()
        }
    }
}

// MARK: - Private

private extension AnnounceView {

    func setupInitialState() {
        setupAppearence()
        setupLayout()

        titleLabel.text = L10n.Player.soon
    }
    
    func setupAppearence() {
        iconView.image = config.image

        titleLabel.font = config.titleFont
        titleLabel.textColor = config.titleColor

        subtitleLabel.font = config.subtitleFont
        subtitleLabel.textColor = config.subtitleColor

        backgroundColor = config.backgroundColor
        layer.cornerRadius = 6
        layer.masksToBounds = true
    }

    func setupLayout() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)

        addSubviews(stackView, iconView)
        
        iconView.setContentCompressionResistancePriority(.required, for: .vertical)
        stackView.setContentCompressionResistancePriority(.required, for: .horizontal)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            iconView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            stackView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
