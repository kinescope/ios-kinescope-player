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
        circleView.layer.removeAnimation(forKey: "pulse")
        circleView.alpha = 1
        if animated {
            // Red dot while playback sits on the live edge. Opacity blink matches Android.
            circleView.backgroundColor = config.onColor
            let pulse = CABasicAnimation(keyPath: "opacity")
            pulse.fromValue = 1
            pulse.toValue = 0
            pulse.duration = 0.8
            pulse.autoreverses = true
            pulse.repeatCount = .infinity
            pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            circleView.layer.add(pulse, forKey: "pulse")
        } else {
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
        titleLabel.numberOfLines = 1
        titleLabel.textColor = config.titleColor
        titleLabel.text = L10n.Player.live
        stackView.addArrangedSubview(titleLabel)
    }

    func configureCircle() {
        circleView.layer.cornerRadius = config.circleRadius
        circleView.clipsToBounds = true
        circleView.backgroundColor = config.offColor
        circleView.squareSize(with: config.circleRadius * 2)
        stackView.addArrangedSubview(circleView)
    }
}
