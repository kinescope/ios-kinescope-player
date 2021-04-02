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

    private var isTouching = false
    private var isAnimating = false

    weak var output: TimelineOutput?

    init(config: KinescopePlayerTimelineConfiguration) {
        self.config = config
        super.init(frame: .zero)
        setupInitialState(with: config)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Touches

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {

        guard isTouchInside else {
            return false
        }

        isTouching = true

        let point = touch.location(in: self)

        updateFrames(with: point.x)

        return true
    }


    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {

        isTouching = false

        guard let point = touch?.location(in: self) else {
            return
        }

        isAnimating = true

        let relativePosition = point.x / frame.width

        output?.onTimelinePositionChanged(to: relativePosition)

        UIView.animate(withDuration: 0.2,
                       animations: { [weak self] in
                        self?.updateFrames(with: point.x)
                       },
                       completion: { [weak self] _ in
                        self?.isAnimating = false
                       })

    }

}

// MARK: - TimelineInput

extension TimelineView: TimelineInput {

    func setTimeline(to position: CGFloat) {

        guard !isTouching && !isAnimating else {
            return
        }

        updateFrames(with: position * frame.width)
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
        view.isUserInteractionEnabled = false
        return view
    }

    func createCircle(with color: UIColor, radius: CGFloat) -> UIView {
        let view = UIView(frame: .init(origin: .zero, size: .init(width: radius * 2, height: radius * 2)))
        view.backgroundColor = color
        view.layer.cornerRadius = radius
        view.isUserInteractionEnabled = false
        return view
    }

    func updateFrames(with circleX: CGFloat) {

        // Keep center in view bounds
        let normalizedX: CGFloat = {
            if circleX < config.circleRadius {
                return config.circleRadius
            } else if circleX > frame.width - config.circleRadius {
                return frame.width - config.circleRadius
            } else {
                return circleX
            }
        }()

        let centerY = frame.height / 2

        circleView.center = .init(x: normalizedX, y: centerY)

        let progressOrigin = CGPoint(x: config.circleRadius, y: centerY - config.lineHeight / 2)

        futureProgress.frame = .init(origin: progressOrigin,
                                     size: .init(width: frame.width - config.circleRadius * 2,
                                                 height: config.lineHeight))

        pastProgress.frame = .init(origin: progressOrigin,
                                     size: .init(width: normalizedX,
                                                 height: config.lineHeight))
    }

}
