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

/// Configurable time indicator(clock) view
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

    func getIndicatorWidth(with duration: TimeInterval) -> CGFloat {
        let label = UILabel()
        label.font = monospacedFont()
        label.text = getText(from: duration)
        label.sizeToFit()
        return label.frame.size.width
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
        label.font = monospacedFont()
        label.textAlignment = .center

        addSubview(label)
        stretch(view: label)

        label.text = getText(from: 0)
    }

    func getText(from time: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: time)
        let duration = KinescopeVideoDuration.from(raw: time)
        formatter.dateFormat = duration.rawValue
        return formatter.string(from: date)
    }

    func monospacedFont() -> UIFont {
        let fontFeatures = [
            [
                UIFontDescriptor.FeatureKey.featureIdentifier: kNumberSpacingType,
                UIFontDescriptor.FeatureKey.typeIdentifier: kMonospacedNumbersSelector
            ]
        ]
        let descriptorWithFeatures = UIFont.systemFont(ofSize: config.fontSize)
            .fontDescriptor
            .addingAttributes([UIFontDescriptor.AttributeName.featureSettings: fontFeatures])
        return UIFont(descriptor: descriptorWithFeatures, size: config.fontSize)
    }

}
