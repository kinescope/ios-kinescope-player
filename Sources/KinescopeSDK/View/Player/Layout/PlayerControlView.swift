//
//  PlayerControlView.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//
// swiftlint:disable implicitly_unwrapped_optional

import UIKit

protocol PlayerControlInput: TimelineInput, TimeIndicatorInput, PlayerControlOptionsInput { 
    func set(live: Bool?)
    func set(chapters: [KinescopeChapterMark], duration: TimeInterval)
}

protocol PlayerControlOutput: TimelineOutput {
    func didSelect(option: KinescopePlayerOption)
    func didTapLive()
}

class PlayerControlView: UIControl {

    private enum Constants {
        static let scrubTitleGap: CGFloat = 8
        static let scrubTitleInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
    }
    
    private(set) var liveIndicator: LiveIndicatorView!
    private(set) var timeIndicator: TimeIndicatorView!
    private(set) var timeline: TimelineView!
    private(set) var optionsMenu: PlayerControlOptionsView!
    private let scrubTitleLabel = PaddingLabel(insets: Constants.scrubTitleInsets)

    private var chapters: [KinescopeChapterMark] = []
    private var chaptersDuration: TimeInterval = 0

    private let config: KinescopeControlPanelConfiguration

    weak var output: PlayerControlOutput?

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

    // MARK: - Internal Properties

    var expanded: Bool = false {
        didSet {
            guard oldValue != expanded else {
                return
            }
            animateOptions(expanded)
        }
    }

    private var timelineTrailing: NSLayoutConstraint?
    private var timelineLeading: NSLayoutConstraint?
    private var optionsWidth: NSLayoutConstraint?

}

// MARK: - PlayerControlInput

extension PlayerControlView: PlayerControlInput {

    func getCustomOptionView(by id: AnyHashable) -> UIView? {
        optionsMenu.getCustomOptionView(by: id)
    }

    func set(live: Bool?) {
        let liveMode = live != nil
        timeIndicator.isHidden = liveMode
        liveIndicator.isHidden = !liveMode
        if let live {
            liveIndicator.set(animated: live)
        }
        pinTimeline(afterLiveBadge: liveMode)
    }

    func setTimeline(to position: CGFloat) {
        timeline.setTimeline(to: position)
    }

    func setBufferred(progress: CGFloat) {
        timeline.setBufferred(progress: progress)
    }

    func setChapters(starts: [CGFloat]) {
        timeline.setChapters(starts: starts)
    }

    func set(chapters: [KinescopeChapterMark], duration: TimeInterval) {
        self.chapters = chapters
        self.chaptersDuration = duration
        guard duration > 0 else {
            timeline.setChapters(starts: [])
            return
        }
        timeline.setChapters(starts: chapters.map { CGFloat($0.start / duration) })
    }

    func set(settingsBadgeFor height: CGFloat) {
        optionsMenu.set(settingsBadgeFor: height)
    }

    func setIndicator(to time: TimeInterval, duration: TimeInterval?) {
        timeIndicator.setIndicator(to: time, duration: duration)
    }

    func set(options: [KinescopePlayerOption]) {
        optionsMenu.set(options: options)
        optionsWidth?.constant = optionsMenu.laidOutWidth
    }

    func set(subtitleOn: Bool) {
        optionsMenu.set(subtitleOn: subtitleOn)
    }

    func set(fullscreenOn: Bool) {
        optionsMenu.set(fullscreenOn: fullscreenOn)
    }

    func setVisible(_ visible: Bool, animated: Bool) {
        layer.removeAllAnimations()
        invalidateAnimatedVisibility()
        isUserInteractionEnabled = visible
        guard animated else {
            alpha = visible ? 1 : 0
            isHidden = !visible
            return
        }
        if visible {
            showAnimated()
        } else {
            hideAnimated()
        }
    }

}

// MARK: - PlayerControlOptionsOutput

extension PlayerControlView: PlayerControlOptionsOutput {

    func didOptions(expanded: Bool) {
        self.expanded = expanded
    }

    func didSelect(option: KinescopePlayerOption) {
        switch option {
        case .more:
            self.expanded.toggle()
        default:
            break
        }
        output?.didSelect(option: option)
    }

}

// MARK: - TimelineOutput

extension PlayerControlView: TimelineOutput {

    func onUpdate() {
        scrubTitleLabel.isHidden = true
        output?.onUpdate()
    }

    func onTimelinePositionChanged(to position: CGFloat) {
        updateScrubTitle(position: position)
        output?.onTimelinePositionChanged(to: position)
    }

}

// MARK: - Private

private extension PlayerControlView {

    func setupInitialState(with config: KinescopeControlPanelConfiguration) {
        // configure control panel

        backgroundColor = config.backgroundColor
        
        liveIndicator = LiveIndicatorView(config: config.liveIndicator)
        timeIndicator = TimeIndicatorView(config: config.timeIndicator)
        timeline = TimelineView(config: config.timeline)
        optionsMenu = PlayerControlOptionsView(config: config.optionsMenu)

        addSubviews(liveIndicator, timeIndicator, timeline, optionsMenu)

        setupConstraints()
        configureScrubTitle()

        optionsMenu.output = self
        timeline.output = self

        liveIndicator.isUserInteractionEnabled = true
        liveIndicator.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(liveTapped)))
    }

    @objc
    func liveTapped() {
        output?.didTapLive()
    }

    func configureScrubTitle() {
        scrubTitleLabel.font = .systemFont(ofSize: 14)
        scrubTitleLabel.textColor = .white
        scrubTitleLabel.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        scrubTitleLabel.isHidden = true
        scrubTitleLabel.isUserInteractionEnabled = false
        scrubTitleLabel.lineBreakMode = .byTruncatingTail
        addSubview(scrubTitleLabel)
    }

    func updateScrubTitle(position: CGFloat) {
        guard chaptersDuration > 0,
              let current = chapters.chapter(at: TimeInterval(position) * chaptersDuration) else {
            scrubTitleLabel.isHidden = true
            return
        }
        scrubTitleLabel.text = current.chapter.title
        scrubTitleLabel.isHidden = false

        let trackFrame = timeline.frame
        let maxWidth = trackFrame.width
        var size = scrubTitleLabel.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
        size.width = min(size.width, maxWidth)
        let anchorX = trackFrame.minX + trackFrame.width * position
        let minX = trackFrame.minX
        let maxX = max(minX, trackFrame.maxX - size.width)
        let x = min(max(anchorX - size.width / 2, minX), maxX)
        let lineTop = trackFrame.midY - config.timeline.lineHeight / 2
        scrubTitleLabel.frame = CGRect(x: x, y: lineTop - Constants.scrubTitleGap - size.height,
                                       width: size.width, height: size.height)
    }

    func setupConstraints() {
        timeIndicator.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        timeIndicator.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        liveIndicator.setContentCompressionResistancePriority(.required, for: .horizontal)
        liveIndicator.setContentHuggingPriority(.required, for: .horizontal)
        liveIndicator.isHidden = true

        timeline.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        timeline.setContentHuggingPriority(.defaultLow, for: .horizontal)

        optionsMenu.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        optionsMenu.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        optionsMenu.setContentHuggingPriority(.defaultLow, for: .vertical)
        optionsMenu.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: config.preferedHeight),
            liveIndicator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            liveIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            timeIndicator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            timeIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            timeline.topAnchor.constraint(equalTo: topAnchor),
            timeline.bottomAnchor.constraint(equalTo: bottomAnchor),
            optionsMenu.centerYAnchor.constraint(equalTo: centerYAnchor),
            optionsMenu.heightAnchor.constraint(equalToConstant: 44),
            optionsMenu.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4)
        ])
        optionsMenu.clipsToBounds = true
        optionsWidth = optionsMenu.widthAnchor.constraint(equalToConstant: optionsMenu.laidOutWidth)
        optionsWidth?.isActive = true
        pinTimeline(afterLiveBadge: false)
        let trailing = timeline.trailingAnchor.constraint(equalTo: optionsMenu.leadingAnchor, constant: -12)
        trailing.isActive = true
        timelineTrailing = trailing
    }

    /// Seek bar starts after the clock, or after the LIVE badge so the badge does not cover the track.
    func pinTimeline(afterLiveBadge liveMode: Bool) {
        timelineLeading?.isActive = false
        let anchor = liveMode ? liveIndicator.trailingAnchor : timeIndicator.trailingAnchor
        let leading = timeline.leadingAnchor.constraint(equalTo: anchor, constant: liveMode ? 8 : 12)
        leading.isActive = true
        timelineLeading = leading
    }

    /// Buttons stay in one row. The seek bar keeps its trailing pin and just gives up space.
    func animateOptions(_ expanded: Bool) {
        optionsMenu.isExpanded = expanded
        let showingLive = !liveIndicator.isHidden
        if !expanded {
            timeIndicator.isHidden = showingLive
        }
        optionsMenu.setExtraWidths(revealed: expanded)
        optionsWidth?.constant = optionsMenu.laidOutWidth

        let animator = UIViewPropertyAnimator(duration: 0.2,
                                              timingParameters: UICubicTimingParameters(controlPoint1: CGPoint(x: 0.4, y: 0),
                                                                                        controlPoint2: CGPoint(x: 0.2, y: 1)))
        animator.addAnimations {
            self.optionsMenu.setExtraAlpha(revealed: expanded)
            self.timeIndicator.alpha = expanded ? 0 : 1
            self.liveIndicator.alpha = expanded ? 0 : 1
            self.timeline.alpha = expanded ? 0 : 1
            self.layoutIfNeeded()
        }
        animator.addCompletion { [weak self] _ in
            guard let self else { return }
            self.timeIndicator.isHidden = expanded || !self.liveIndicator.isHidden
            if !expanded {
                self.timeIndicator.alpha = 1
                self.liveIndicator.alpha = 1
                self.timeline.alpha = 1
            }
        }
        animator.startAnimation()
    }

}
