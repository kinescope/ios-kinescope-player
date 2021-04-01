//
//  PlayerControlView.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//
// swiftlint:disable implicitly_unwrapped_optional

import UIKit

protocol PlayerControlInput: TimelineInput, TimeIndicatorInput, PlayerControlOptionsInput {}

protocol PlayerControlOutput: TimelineOutput {}

class PlayerControlView: UIControl {

    private(set) var timeIndicator: TimeIndicatorView!
    private(set) var timeline: TimelineView!
    private(set) var optionsMenu: PlayerControlOptionsView!

    private let config: KinescopeControlPanelConfiguration

    init(config: KinescopeControlPanelConfiguration) {
        self.config = config
        super.init(frame: .zero)
        setupInitialState(with: config)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        .init(width: .greatestFiniteMagnitude, height: config.preferedHeight)
    }

}

// MARK: - Private

private extension PlayerControlView {

    func setupInitialState(with config: KinescopeControlPanelConfiguration) {
        // configure control panel

        backgroundColor = config.backgroundColor

        timeIndicator = TimeIndicatorView(config: config.timeIndicator)
        timeline = TimelineView(config: config.timeline)
        optionsMenu = PlayerControlOptionsView(config: config.optionsMenu)

        addSubviews(timeIndicator, timeline, optionsMenu)

        setupConstraints()

        optionsMenu.set(options: [.settings, .fullscreen, .more])
    }

    func setupConstraints() {

        subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        timeIndicator.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        timeIndicator.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        timeline.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        timeline.setContentHuggingPriority(.defaultLow, for: .horizontal)

        optionsMenu.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        optionsMenu.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        NSLayoutConstraint.activate([
            timeIndicator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            timeIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            timeline.leadingAnchor.constraint(equalTo: timeIndicator.trailingAnchor, constant: 16),
            timeline.centerYAnchor.constraint(equalTo: centerYAnchor),
            timeline.trailingAnchor.constraint(equalTo: optionsMenu.leadingAnchor, constant: -16),
            optionsMenu.centerYAnchor.constraint(equalTo: centerYAnchor),
            optionsMenu.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])

    }

}
