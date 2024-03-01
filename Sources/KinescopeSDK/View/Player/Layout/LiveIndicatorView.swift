//
//  LiveIndicatorView.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 01.03.2024.
//

import UIKit

protocol LiveIndicatorInput {
    
    /// Enable or disable animation
    func set(animated: Bool)
}

final class LiveIndicatorView: UIView {
    
    // MARK: - Properties

    private let titleLabel = UILabel()
    private let circleView = UIView()
    private let config: KinescopeLiveIndicatorConfiguration
    private let stackView = UIStackView()

    // MARK: - Lifecycle

    init(config: KinescopeLiveIndicatorConfiguration) {
        self.config = config
        super.init(frame: .zero)
        self.setupInitialState()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - LiveIndicatorInput

extension LiveIndicatorView: LiveIndicatorInput {

    func set(animated: Bool) {
        if animated {
            let animation = CABasicAnimation(keyPath: "backgroundColor")
            animation.fromValue = config.offColor.cgColor
            animation.toValue = config.onColor.cgColor
            animation.duration = 1
            animation.autoreverses = true
            animation.repeatCount = .infinity
            circleView.layer.add(animation, forKey: "backgroundColor")
        } else {
            circleView.layer.removeAllAnimations()
            circleView.backgroundColor = config.offColor
        }
    }
}

// MARK: - Private

private extension LiveIndicatorView {
    func setupInitialState() {
        configureStackView()
        configureCircle()
        configureTitleLabel()
    }

    func configureStackView() {
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 4.0
        addSubview(stackView)
        stretch(view: stackView)
    }

    func configureTitleLabel() {
        titleLabel.font = config.titleFont
        titleLabel.numberOfLines = 2
        titleLabel.textColor = config.titleColor
        titleLabel.text = L10n.Player.live
        stackView.addArrangedSubview(titleLabel)
    }

    func configureCircle() {
        circleView.layer.cornerRadius = config.circleRadius
        circleView.backgroundColor = config.offColor
        circleView.squareSize(with: config.circleRadius * 2)
        stackView.addArrangedSubview(circleView)
    }
}
