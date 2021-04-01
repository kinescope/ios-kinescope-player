//
//  TimelineView.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 31.03.2021.
//

import UIKit

protocol TimelineInput {

    /// Update timeline position manualy
    ///
    /// - parameter position: Value from `0` (start) to `1` (end)
    func setTimeline(to position: CGFloat)
}

protocol TimelineOutput: class {

    /// Callback of user initiated timeline changes like circle dragging or tap released
    ///
    /// - parameter position: Value from `0` (start) to `1` (end)
    func onTimelinePositionChanged(to position: CGFloat)

}

class TimelineView: UIControl {

    private weak var circleView: UIView!
    private weak var futureProgress: UIView!
    private weak var pastProgress: UIView!
    private weak var preloadProgress: UIView!

    private let config: KinescopePlayerTimelineConfiguration

    weak var output: TimelineOutput?

    init(config: KinescopePlayerTimelineConfiguration) {
        self.config = config
        super.init(frame: .zero)
        setupInitialState(with: config)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        .init(width: config.circleRadius * 10, height: config.circleRadius * 4)
    }

    // MARK: - Touches

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        return false
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {

    }

}

// MARK: - TimelineInput

extension TimelineView: TimelineInput {

    func setTimeline(to position: CGFloat) {
        // TODO: - устанавливать таймлайн

        let circleX = position * frame.width
        let centerY = frame.height / 2

        circleView.center = .init(x: circleX, y: centerY)

        let progressOrigin = CGPoint(x: config.circleRadius, y: centerY)

        futureProgress.frame = .init(origin: progressOrigin,
                                     size: .init(width: frame.width - config.circleRadius * 2,
                                                 height: config.lineHeight))

        pastProgress.frame = .init(origin: progressOrigin,
                                     size: .init(width: circleX,
                                                 height: config.lineHeight))
    }

}

// MARK: - Private

private extension TimelineView {

    func setupInitialState(with config: KinescopePlayerTimelineConfiguration) {

        backgroundColor = .clear

        let futureProgress = createLine(with: config.inactiveColor, and: config.lineHeight)
        addSubview(futureProgress)
        self.futureProgress = futureProgress

        let preloadProgress = createLine(with: config.inactiveColor, and: config.lineHeight)
        addSubview(preloadProgress)
        self.preloadProgress = preloadProgress

        let pastProgress = createLine(with: config.activeColor, and: config.lineHeight)
        addSubview(pastProgress)
        self.pastProgress = pastProgress

        let circleView = createCircle(with: config.activeColor, radius: config.circleRadius)
        addSubview(circleView)
        self.circleView = circleView
    }

    func createLine(with color: UIColor, and height: CGFloat) -> UIView {
        let view = UIView(frame: .init(origin: .zero, size: .init(width: .zero, height: height)))
        view.backgroundColor = color
        return view
    }

    func createCircle(with color: UIColor, radius: CGFloat) -> UIView {
        let view = UIView(frame: .init(origin: .zero, size: .init(width: radius * 2, height: radius * 2)))
        view.backgroundColor = color
        view.layer.cornerRadius = radius
        return view
    }

}
