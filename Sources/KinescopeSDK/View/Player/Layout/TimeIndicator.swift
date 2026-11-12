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
    /// - parameter duration: Total duration of video. `nil` if unknown.
    func setIndicator(to time: TimeInterval, duration: TimeInterval?)
}

class TimeIndicatorView: UIView {

    private let config: KinescopePlayerTimeindicatorConfiguration
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    private let positionLabel = UILabel()
    private let durationLabel = UILabel()
    private let durationClip = UIView()
    private var durationClipWidth: NSLayoutConstraint?
    private var time: TimeInterval = 0
    private var duration: TimeInterval?
    private var showsDurationSuffix = false
    private var suffixLink: CADisplayLink?
    private var suffixStarted: CFTimeInterval = 0
    private var suffixFrom: CGFloat = 0
    private var suffixTo: CGFloat = 0

    init(config: KinescopePlayerTimeindicatorConfiguration) {
        self.config = config
        super.init(frame: .zero)
        setupInitialState(with: config)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        suffixLink?.invalidate()
    }

    override var intrinsicContentSize: CGSize {
        let height = monospacedFont().lineHeight
        let width = ceil(positionLabel.intrinsicContentSize.width + (durationClipWidth?.constant ?? 0))
        return .init(width: width, height: height)
    }

}

// MARK: - TimeIndicatorInput

extension TimeIndicatorView: TimeIndicatorInput {

    func setIndicator(to time: TimeInterval, duration: TimeInterval?) {
        let validDuration = duration.flatMap { $0.isFinite && $0 > 0 ? $0 : nil }
        let oldFormat = format(for: self.duration ?? self.time)

        self.time = max(0, time)
        self.duration = validDuration

        if format(for: self.duration ?? self.time) != oldFormat {
            invalidateIntrinsicContentSize()
        }
        updateText()
    }

}

// MARK: - Private

private extension TimeIndicatorView {

    func setupInitialState(with config: KinescopePlayerTimeindicatorConfiguration) {
        backgroundColor = .clear
        configureLabel()
        configureTap()
    }

    func configureLabel() {
        let font = monospacedFont()
        positionLabel.textColor = config.color
        positionLabel.font = font
        positionLabel.textAlignment = .left
        durationLabel.textColor = config.color.withAlphaComponent(0.64)
        durationLabel.font = font
        durationClip.clipsToBounds = true
        durationClip.isHidden = true

        addSubview(positionLabel)
        addSubview(durationClip)
        durationClip.addSubview(durationLabel)
        positionLabel.translatesAutoresizingMaskIntoConstraints = false
        durationClip.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        let clipWidth = durationClip.widthAnchor.constraint(equalToConstant: 0)
        durationClipWidth = clipWidth
        NSLayoutConstraint.activate([
            positionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            positionLabel.topAnchor.constraint(equalTo: topAnchor),
            positionLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            durationClip.leadingAnchor.constraint(equalTo: positionLabel.trailingAnchor),
            durationClip.topAnchor.constraint(equalTo: topAnchor),
            durationClip.bottomAnchor.constraint(equalTo: bottomAnchor),
            durationClip.trailingAnchor.constraint(equalTo: trailingAnchor),
            clipWidth,
            durationLabel.leadingAnchor.constraint(equalTo: durationClip.leadingAnchor),
            durationLabel.centerYAnchor.constraint(equalTo: durationClip.centerYAnchor)
        ])
        updateText()
    }

    func configureTap() {
        guard config.showsDuration else {
            return
        }
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleMode)))
    }

    @objc
    func toggleMode() {
        guard duration != nil else {
            return
        }
        showsDurationSuffix.toggle()
        animateSuffix(shown: showsDurationSuffix)
    }

    func updateText() {
        positionLabel.text = getText(from: time, format: format(for: duration ?? time))
        if let duration {
            durationLabel.text = " / " + getText(from: duration, format: format(for: duration))
        } else {
            durationLabel.text = nil
            showsDurationSuffix = false
        }
        if suffixLink == nil {
            applySuffix(progress: showsDurationSuffix ? 1 : 0)
        }
        invalidateIntrinsicContentSize()
    }

    /// Duration suffix clips open and shut, same as Android: 100ms, fade only after 40%.
    func animateSuffix(shown: Bool) {
        suffixLink?.invalidate()
        let target = durationLabel.intrinsicContentSize.width
        guard target > 0 else {
            applySuffix(progress: 0)
            return
        }
        let current = durationClipWidth?.constant ?? 0
        suffixFrom = min(1, current / target)
        suffixTo = shown ? 1 : 0
        suffixStarted = CACurrentMediaTime()
        let link = CADisplayLink(target: self, selector: #selector(stepSuffix))
        link.add(to: .main, forMode: .common)
        suffixLink = link
    }

    @objc
    func stepSuffix() {
        let elapsed = CGFloat(CACurrentMediaTime() - suffixStarted)
        let linear = min(1, elapsed / 0.1)
        let eased = Self.fastOutSlowIn(linear)
        let progress = suffixFrom + (suffixTo - suffixFrom) * eased
        applySuffix(progress: progress)
        if linear >= 1 {
            suffixLink?.invalidate()
            suffixLink = nil
            applySuffix(progress: suffixTo)
        }
    }

    func applySuffix(progress: CGFloat) {
        let clamped = min(1, max(0, progress))
        let width = durationLabel.intrinsicContentSize.width * clamped
        durationClipWidth?.constant = width
        durationLabel.alpha = clamped <= 0.4 ? 0 : (clamped - 0.4) / 0.6
        durationClip.isHidden = clamped == 0
        invalidateIntrinsicContentSize()
    }

    static func fastOutSlowIn(_ amount: CGFloat) -> CGFloat {
        var low: CGFloat = 0
        var high: CGFloat = 1
        for _ in 0..<10 {
            let middle = (low + high) / 2
            if Self.bezier(middle, 0.4, 0.2) < amount {
                low = middle
            } else {
                high = middle
            }
        }
        return Self.bezier((low + high) / 2, 0, 1)
    }

    static func bezier(_ t: CGFloat, _ first: CGFloat, _ second: CGFloat) -> CGFloat {
        let inverse = 1 - t
        return 3 * inverse * inverse * t * first + 3 * inverse * t * t * second + t * t * t
    }

    func format(for reference: TimeInterval) -> KinescopeVideoDuration {
        KinescopeVideoDuration.from(raw: reference)
    }

    func getText(from time: TimeInterval, format: KinescopeVideoDuration) -> String {
        let date = Date(timeIntervalSince1970: time.isFinite ? time : 0)
        formatter.dateFormat = format.rawValue
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
