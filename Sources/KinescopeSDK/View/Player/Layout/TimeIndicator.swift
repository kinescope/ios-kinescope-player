//
//  TimeIndicator.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 31.03.2021.
//

import UIKit

protocol TimeIndicatorInput {

    /// Update time value
    ///
    /// - parameter time: Positive time interval describes current moment in video
    func setIndicator(to time: TimeInterval)
}

class TimeIndicatorView: UIView {

    private let label = UILabel()

    private let config: KinescopePlayerTimeindicatorConfiguration
    private let formatter = DateFormatter()

    init(config: KinescopePlayerTimeindicatorConfiguration) {
        self.config = config
        super.init(frame: .zero)
        setupInitialState(with: config)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        let label = UILabel()
        label.font = config.font
        label.text = getText(from: .infinity)
        label.sizeToFit()
        return .init(width: label.frame.size.width, height: config.font.lineHeight)
    }

}

// MARK: - TimeIndicatorInput

extension TimeIndicatorView: TimeIndicatorInput {

    func setIndicator(to time: TimeInterval) {
        label.text = getText(from: time)
    }

}

// MARK: - Private

private extension TimeIndicatorView {

    func setupInitialState(with config: KinescopePlayerTimeindicatorConfiguration) {

        backgroundColor = .clear

        configureLabel()
    }

    func configureLabel() {
        label.textColor = config.color
        label.font = config.font
        label.textAlignment = .right

        addSubview(label)
        stretch(view: label)

        label.text = getText(from: 0)
    }

    func getText(from time: TimeInterval) -> String {

        let date = Date(timeIntervalSince1970: 0)

        let duration = KinescopeVideoDuration.from(raw: time)

        formatter.dateFormat = duration.rawValue

        return formatter.string(from: date)
    }
}
