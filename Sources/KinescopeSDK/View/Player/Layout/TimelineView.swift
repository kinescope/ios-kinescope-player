//
//  TimelineView.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 31.03.2021.
//
// swiftlint:disable implicitly_unwrapped_optional

import UIKit

protocol TimelineInput {

    /// Update timeline position manualy
    ///
    /// - parameter position: Value from `0` (start) to `1` (end)
    func setTimeline(to position: CGFloat)

    /// Update timeline position manualy
    ///
    /// - parameter progress: Value from `0` (start) to `1` (end)
    func setBufferred(progress: CGFloat)
}

protocol TimelineOutput: class {

    /// Callback of user initiated timeline changes like circle dragging
    ///
    /// - parameter position: Value from `0` (start) to `1` (end)
    func onTimelinePositionChanged(to position: CGFloat)

    /// Triggers update
    func onUpdate()

}

class TimelineView: UIControl {

    private weak var circleView: UIView!
    private weak var activeCircleView: UIView!
    private weak var futureProgress: UIView!
    private weak var pastProgress: UIView!
    private weak var preloadProgress: UIView!

    private let config: KinescopePlayerTimelineConfiguration

    private var isTouching = false {
        didSet {
            activeCircleView.isHidden = !isTouching
        }
    }

    weak var output: TimelineOutput?

    init(config: KinescopePlayerTimelineConfiguration) {
        self.config = config
        super.init(frame: .zero)
        setupInitialState(with: config)

        addTarget(self, action: #selector(endTouch),
                  for: UIControl.Event.touchUpOutside)
        addTarget(self, action: #selector(endTouch),
                  for: UIControl.Event.touchUpInside)
        addTarget(self, action: #selector(continueTouch),
                  for: UIControl.Event.touchDragInside)
        addTarget(self, action: #selector(continueTouch),
                  for: UIControl.Event.touchDragOutside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Touches

private extension TimelineView {

    @objc
    func continueTouch(control: TimelineView, withEvent event: UIEvent) {
        guard let touch = event.touches(for: control)?.first else {
            return
        }
        isTouching = true

        let point = touch.location(in: self)
        let relativePosition = getRelativePosition(from: point.x)
        output?.onTimelinePositionChanged(to: relativePosition)
        updateFrames(with: point.x)
    }

    @objc
    func endTouch(control: TimelineView, withEvent event: UIEvent) {
        guard let touch = event.touches(for: control)?.first else {
            return
        }

        isTouching = false

        let point = touch.location(in: self)
        let relativePosition = getRelativePosition(from: point.x)
        output?.onTimelinePositionChanged(to: relativePosition)
        output?.onUpdate()
        updateFrames(with: point.x)
    }

}

// MARK: - TimelineInput

extension TimelineView: TimelineInput {

    func setTimeline(to position: CGFloat) {
        guard !isTouching else {
            return
        }

        let coordinate = getCoordinateFrom(current: position)
        updateFrames(with: coordinate)
    }

    func setBufferred(progress: CGFloat) {
        let coordinate = getCoordinateFrom(preload: progress)
        updatePreloadFrames(with: coordinate)
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

        let activeCircleView = createCircle(with: UIColor(red: 1, green: 1, blue: 1, alpha: 0.16), radius: config.circleRadius + 4)
        addSubview(activeCircleView)
        self.activeCircleView = activeCircleView
        self.activeCircleView.isHidden = true

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

        let normalizedX = getNormalisedCoordinate(from: circleX)

        let centerY = frame.height / 2

        circleView.center = .init(x: normalizedX, y: centerY)
        activeCircleView.center = .init(x: normalizedX, y: centerY)

        let progressOrigin = CGPoint(x: config.circleRadius, y: centerY - config.lineHeight / 2)

        futureProgress.frame = .init(origin: progressOrigin,
                                     size: .init(width: frame.width - config.circleRadius * 2,
                                                 height: config.lineHeight))

        pastProgress.frame = .init(origin: progressOrigin,
                                     size: .init(width: normalizedX,
                                                 height: config.lineHeight))
    }

    func updatePreloadFrames(with position: CGFloat) {

        let normalizedX = getNormalisedCoordinate(from: position)

        let centerY = frame.height / 2

        let progressOrigin = CGPoint(x: config.circleRadius, y: centerY - config.lineHeight / 2)

        preloadProgress.frame = .init(origin: progressOrigin,
                                      size: .init(width: normalizedX,
                                                  height: config.lineHeight))
    }

    /// Convert circle center coordinate to relative value from `0` to `1`
    func getRelativePosition(from coordinate: CGFloat) -> CGFloat {
        let normalisedCoordinate = getNormalisedCoordinate(from: coordinate) - config.circleRadius
        return normalisedCoordinate / futureProgress.frame.width
    }

    /// Convert relative value from `0` to `1` to circle center coordinate
    func getCoordinateFrom(current position: CGFloat) -> CGFloat {
        position * futureProgress.frame.width + config.circleRadius
    }

    /// Convert relative value from `0` to `1` to circle center coordinate
    func getCoordinateFrom(preload position: CGFloat) -> CGFloat {
        position * futureProgress.frame.width
    }

    /// Keep circle center x in view bounds
    func getNormalisedCoordinate(from coordinate: CGFloat) -> CGFloat {
        if coordinate < config.circleRadius {
            return config.circleRadius
        } else if coordinate > frame.width - config.circleRadius {
            return frame.width - config.circleRadius
        } else {
            return coordinate
        }
    }

}
