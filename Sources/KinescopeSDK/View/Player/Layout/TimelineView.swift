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

    /// Update timeline position manualy
    ///
    /// - parameter progress: Value from `0` (start) to `1` (end)
    func setBufferred(progress: CGFloat)

    /// Split timeline into chapter segments.
    ///
    /// - parameter starts: Relative chapter starts from `0` to `1`
    func setChapters(starts: [CGFloat])
}

protocol TimelineOutput: AnyObject {

    /// Callback of user initiated timeline changes like circle dragging
    ///
    /// - parameter position: Value from `0` (start) to `1` (end)
    func onTimelinePositionChanged(to position: CGFloat)

    /// Triggers update
    func onUpdate()

}

class TimelineView: UIControl {

    private enum Constants {
        static let chapterGap: CGFloat = 2
        static let scrubHeightScale: CGFloat = 1.85
        static let scrubCornerRadius: CGFloat = 2
        static let scrubAnimationDuration: CFTimeInterval = 0.15
    }

    private let trackLayer = CALayer()
    private let bufferedLayer = CALayer()
    private let playedLayer = CALayer()
    private let segmentsMask = CAShapeLayer()
    private let heightDriver = DisplayLinkDriver()

    private let config: KinescopePlayerTimelineConfiguration

    private var position: CGFloat = 0
    private var buffered: CGFloat = 0
    private var chapterStarts: [CGFloat] = []
    private var barHeight: CGFloat = 0

    private(set) var isTouching = false {
        didSet {
            guard oldValue != isTouching else {
                return
            }
            let target = isTouching ? config.lineHeight * Constants.scrubHeightScale : config.lineHeight
            heightDriver.animate(from: barHeight, to: target, duration: Constants.scrubAnimationDuration) { [weak self] value in
                self?.barHeight = value
                self?.updateTrackGeometry()
                self?.updateProgressFrames()
            }
        }
    }

    weak var output: TimelineOutput?

    init(config: KinescopePlayerTimelineConfiguration) {
        self.config = config
        self.barHeight = config.lineHeight
        super.init(frame: .zero)
        setupInitialState()
    }

    deinit {
        heightDriver.invalidate()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateTrackGeometry()
        updateProgressFrames()
    }

    // MARK: - Tracking

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        isTouching = true
        handleTouch(at: touch.location(in: self))
        return true
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        handleTouch(at: touch.location(in: self))
        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if let touch {
            handleTouch(at: touch.location(in: self))
        }
        isTouching = false
        output?.onUpdate()
    }

    override func cancelTracking(with event: UIEvent?) {
        isTouching = false
        output?.onUpdate()
    }

}

// MARK: - TimelineInput

extension TimelineView: TimelineInput {

    func setTimeline(to position: CGFloat) {
        guard !isTouching else {
            return
        }
        self.position = clamp(position)
        updateProgressFrames()
    }

    func setBufferred(progress: CGFloat) {
        buffered = clamp(progress)
        updateProgressFrames()
    }

    func setChapters(starts: [CGFloat]) {
        chapterStarts = starts.map(clamp).filter { $0 > 0 && $0 < 1 }.sorted()
        updateTrackGeometry()
    }

}

// MARK: - Private

private extension TimelineView {

    var trackInset: CGFloat {
        0
    }

    /// 0 while idle, 1 when the bar is fully grown for scrubbing.
    var scrubExpansion: CGFloat {
        let grown = config.lineHeight * (Constants.scrubHeightScale - 1)
        guard grown > 0 else {
            return 0
        }
        return min(1, max(0, (barHeight - config.lineHeight) / grown))
    }

    var trackWidth: CGFloat {
        max(0, bounds.width - trackInset * 2)
    }

    func setupInitialState() {
        backgroundColor = .clear

        trackLayer.backgroundColor = config.inactiveColor.cgColor
        bufferedLayer.backgroundColor = config.bufferedColor.cgColor
        playedLayer.backgroundColor = config.activeColor.cgColor
        trackLayer.addSublayer(bufferedLayer)
        trackLayer.addSublayer(playedLayer)
        trackLayer.mask = segmentsMask
        layer.addSublayer(trackLayer)
    }

    func handleTouch(at point: CGPoint) {
        guard trackWidth > 0 else {
            return
        }
        position = clamp((point.x - trackInset) / trackWidth)
        updateProgressFrames()
        output?.onTimelinePositionChanged(to: position)
    }

    func updateTrackGeometry() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let height = max(barHeight, 1)
        trackLayer.frame = CGRect(x: trackInset, y: (bounds.height - height) / 2, width: trackWidth, height: height)
        segmentsMask.frame = trackLayer.bounds

        let radius = scrubExpansion * min(Constants.scrubCornerRadius, height / 2)
        let path = CGMutablePath()
        let segments = [0] + chapterStarts + [1]
        let last = segments.count - 2
        for (index, pair) in zip(segments, segments.dropFirst()).enumerated() {
            let start = pair.0
            let end = pair.1
            let leadingGap = start > 0 ? Constants.chapterGap / 2 : 0
            let trailingGap = end < 1 ? Constants.chapterGap / 2 : 0
            let minX = start * trackWidth + leadingGap
            let maxX = end * trackWidth - trailingGap
            guard maxX > minX else {
                continue
            }
            let segmentRadius = index == 0 || index == last ? radius : 0
            let rect = CGRect(x: minX, y: 0, width: maxX - minX, height: height)
            path.addRoundedRect(in: rect, cornerWidth: segmentRadius, cornerHeight: segmentRadius)
        }
        segmentsMask.path = path
        CATransaction.commit()
    }

    func updateProgressFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let height = max(barHeight, 1)
        bufferedLayer.frame = CGRect(x: 0, y: 0, width: max(buffered, position) * trackWidth, height: height)
        playedLayer.frame = CGRect(x: 0, y: 0, width: position * trackWidth, height: height)
        CATransaction.commit()
    }

    func clamp(_ value: CGFloat) -> CGFloat {
        value.isFinite ? min(1, max(0, value)) : 0
    }

}

/// Drives a short eased animation without retaining the view.
private final class DisplayLinkDriver: NSObject {

    private var link: CADisplayLink?
    private var from: CGFloat = 0
    private var to: CGFloat = 0
    private var duration: CFTimeInterval = 0
    private var started: CFTimeInterval = 0
    private var onStep: ((CGFloat) -> Void)?

    func animate(from: CGFloat, to: CGFloat, duration: CFTimeInterval, onStep: @escaping (CGFloat) -> Void) {
        invalidate()
        self.from = from
        self.to = to
        self.duration = duration
        self.onStep = onStep
        started = CACurrentMediaTime()
        let link = CADisplayLink(target: self, selector: #selector(step))
        link.add(to: .main, forMode: .common)
        self.link = link
    }

    func invalidate() {
        link?.invalidate()
        link = nil
        onStep = nil
    }

    @objc
    private func step() {
        let progress = duration > 0 ? min(1, (CACurrentMediaTime() - started) / duration) : 1
        let eased = progress * progress * (3 - 2 * progress)
        onStep?(from + (to - from) * eased)
        if progress >= 1 {
            invalidate()
        }
    }

}
