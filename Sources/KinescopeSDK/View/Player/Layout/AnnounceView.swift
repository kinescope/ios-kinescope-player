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
        let isRussian = Locale.preferredLanguages.first?.hasPrefix("ru") ?? false
        dateFormatter.dateFormat = isRussian ? "d MMMM, HH:mm" : "MMMM d, HH:mm"
        if isRussian {
            dateFormatter.locale = Locale(identifier: "ru_RU")
        }
        return dateFormatter
    }()

    private let config: KinescopeAnnounceConfiguration
    private var startsAt: Date?
    private var countdownTimer: Timer?

    deinit {
        countdownTimer?.invalidate()
    }

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
        self.startsAt = startsAt
        if let startsAt {
            subtitleLabel.text = dateFormatter.string(from: startsAt)
        } else {
            subtitleLabel.text = ""
        }
        updateCountdown()
        scheduleCountdown()
        if isHidden {
            showAnimated()
        }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil {
            countdownTimer?.invalidate()
            countdownTimer = nil
        } else if startsAt != nil {
            scheduleCountdown()
        }
    }
}

// MARK: - Countdown

private extension AnnounceView {

    func scheduleCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        guard startsAt != nil, window != nil else {
            return
        }
        let timer = Timer(timeInterval: 15, repeats: true) { [weak self] _ in
            self?.updateCountdown()
        }
        RunLoop.main.add(timer, forMode: .common)
        countdownTimer = timer
    }

    func updateCountdown() {
        titleLabel.text = Self.countdownTitle(to: startsAt)
    }

    static func countdownTitle(to startsAt: Date?, now: Date = Date()) -> String {
        guard let startsAt else {
            return L10n.Player.soon
        }
        let diff = startsAt.timeIntervalSince(now)
        guard diff > 1 else {
            return L10n.Player.liveAwaiting
        }
        let minutes = max(1, Int(diff / 60))
        let hours = max(1, Int(diff / 3600))
        let days = max(1, Int(diff / 86400))
        if minutes <= 120 {
            return L10n.Player.liveInMinutes(minutes)
        } else if hours <= 48 {
            return L10n.Player.liveInHours(hours)
        } else {
            return L10n.Player.liveInDays(days)
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
