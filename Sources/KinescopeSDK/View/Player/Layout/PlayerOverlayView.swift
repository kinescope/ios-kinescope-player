//
//  PlayerOverlayView.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 30.03.2021.
//

import UIKit

protocol PlayerOverlayInput: VideoNameInput {
    func set(playing: Bool)
    func showReplay()
}

final class PlayerOverlayView: UIControl {

    fileprivate enum SeekDirection {
        case forward
        case backward
    }

    fileprivate struct SeekStreak {
        let direction: SeekDirection
        var total: TimeInterval
        var lastTap: Date
    }

    // MARK: - Properties

    private let headerBand = ChromeGradientBand(edge: .top)
    private let footerBand = ChromeGradientBand(edge: .bottom)
    private let playPauseView: PlayPauseMorphView
    private let forwardFeedback = SeekFeedbackView(edge: .trailing)
    private let backwardFeedback = SeekFeedbackView(edge: .leading)
    private var forwardFeedbackWidth: NSLayoutConstraint?
    private var backwardFeedbackWidth: NSLayoutConstraint?
    private var seekStreak: SeekStreak?
    private var singleTap: UITapGestureRecognizer?
    private var doubleTap: UITapGestureRecognizer?
    private let nameView: VideoNameView
    private let contentView = UIView()
    private let config: KinescopePlayerOverlayConfiguration
    private weak var delegate: PlayerOverlayViewDelegate?
    private var isPlaying = false
    var duration: TimeInterval {
        return config.duration
    }

    /// Portrait video uses the tall oval. Falls back to the player shape before the first frame.
    private var portraitSeekVideo: Bool {
        let video = (superview as? KinescopePlayerView)?.playerView.player?.currentItem?.presentationSize ?? .zero
        if video.width > 1, video.height > 1 {
            return video.height > video.width
        }
        return bounds.height > bounds.width
    }

    // MARK: - Lifecycle

    init(config: KinescopePlayerOverlayConfiguration, delegate: PlayerOverlayViewDelegate? = nil) {
        self.config = config
        self.delegate = delegate
        self.nameView = VideoNameView(config: config.nameConfiguration)
        self.playPauseView = PlayPauseMorphView(backgroundColor: config.playBackgroundColor)
        super.init(frame: .zero)
        self.setupInitialState()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let screen = window?.bounds.size
        let portraitVideo = portraitSeekVideo
        forwardFeedbackWidth?.constant = forwardFeedback.preferredWidth(in: bounds.size,
                                                                        screen: screen,
                                                                        portraitVideo: portraitVideo)
        backwardFeedbackWidth?.constant = backwardFeedback.preferredWidth(in: bounds.size,
                                                                          screen: screen,
                                                                          portraitVideo: portraitVideo)
        let bandHeight = bounds.height * 120 / 432
        headerBand.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bandHeight)
        footerBand.frame = CGRect(x: 0, y: max(0, bounds.height - bandHeight), width: bounds.width, height: bandHeight)
    }

    // MARK: - UIControl

    private var instantSelection = false

    override var isSelected: Bool {
        didSet {
            let updates = { self.contentView.alpha = self.isSelected ? 1.0 : .zero }
            if instantSelection {
                updates()
            } else {
                UIView.animate(withDuration: 0.1, animations: updates)
            }
        }
    }

    /// The dimmed pause card stays hidden until the viewer taps. A new fullscreen
    /// view must not flash it just because the overlay itself is unhidden.
    func hideContentImmediately() {
        contentView.layer.removeAllAnimations()
        instantSelection = true
        isSelected = false
        contentView.alpha = 0
        instantSelection = false
    }

    /// Center play/pause glyph. Hidden while the seek bar is dragged, then restored.
    func setCenterButtonHidden(_ hidden: Bool) {
        let alpha: CGFloat = hidden ? 0 : 1
        guard playPauseView.alpha != alpha else {
            return
        }
        UIView.animate(withDuration: 0.12) {
            self.playPauseView.alpha = alpha
        }
    }
}

// MARK: - PlayerOverlayInput

extension PlayerOverlayView: PlayerOverlayInput {
    func set(title: String, subtitle: String) {
        nameView.set(title: title, subtitle: subtitle)
    }

    func set(playing: Bool) {
        // Finished playback keeps the replay glyph until the viewer starts it again.
        guard !playPauseView.isShowingReplay || playing else {
            return
        }
        guard playing != isPlaying || playPauseView.isShowingReplay && playing else {
            return
        }
        self.isPlaying = playing
        playPauseView.set(playing: playing, animated: contentView.alpha > 0)
    }

    func showReplay() {
        isPlaying = false
        playPauseView.showReplay()
    }
}

// MARK: - Private

private extension PlayerOverlayView {
    func setupInitialState() {
        isSelected = false

        addGestureRecognizers()
        configureSeekFeedback()
        configureContentView()
    }

    func configureContentView() {
        contentView.isUserInteractionEnabled = true
        contentView.backgroundColor = .clear
        addSubview(contentView)
        stretch(view: contentView)

        [headerBand, footerBand].forEach {
            $0.isUserInteractionEnabled = false
            contentView.addSubview($0)
        }
        configureNameView()
        configurePlayPauseView()
        contentView.alpha = 0
    }

    func configurePlayPauseView() {
        contentView.addSubview(playPauseView)
        playPauseView.isUserInteractionEnabled = true
        playPauseView.squareSize(with: config.playBackgroundRadius * 2)
        contentView.centerChild(view: playPauseView)
        let playTap = UITapGestureRecognizer(target: self, action: #selector(playButtonTapped))
        playPauseView.addGestureRecognizer(playTap)
    }

    func configureSeekFeedback() {
        [backwardFeedback, forwardFeedback].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        let forwardWidth = forwardFeedback.widthAnchor.constraint(equalToConstant: 0)
        let backwardWidth = backwardFeedback.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            backwardFeedback.leadingAnchor.constraint(equalTo: leadingAnchor),
            backwardFeedback.topAnchor.constraint(equalTo: topAnchor),
            backwardFeedback.bottomAnchor.constraint(equalTo: bottomAnchor),
            backwardWidth,
            forwardFeedback.trailingAnchor.constraint(equalTo: trailingAnchor),
            forwardFeedback.topAnchor.constraint(equalTo: topAnchor),
            forwardFeedback.bottomAnchor.constraint(equalTo: bottomAnchor),
            forwardWidth
        ])
        forwardFeedbackWidth = forwardWidth
        backwardFeedbackWidth = backwardWidth
    }

    func configureNameView() {
        contentView.addSubview(nameView)
        contentView.topChildWithSafeArea(view: nameView)
    }

    func addGestureRecognizers() {
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                             action: #selector(singleTapAction))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.delegate = self
        addGestureRecognizer(singleTapGestureRecognizer)
        singleTap = singleTapGestureRecognizer

        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                             action: #selector(doubleTapAction))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.delegate = self
        addGestureRecognizer(doubleTapGestureRecognizer)
        doubleTap = doubleTapGestureRecognizer

        singleTapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
    }

}

// MARK: - Actions

private extension PlayerOverlayView {
    @objc
    func playButtonTapped() {
        playPauseAction()
    }

    func playPauseAction() {
        playPauseView.pulse()
        if playPauseView.isShowingReplay || !isPlaying {
            set(playing: true)
            delegate?.didPlay()
        } else {
            set(playing: false)
            delegate?.didPause()
        }
    }

    @objc
    func singleTapAction(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: contentView)
        let playArea = playPauseView.frame.insetBy(dx: -8, dy: -8)

        if let streak = activeSeekStreak, seekDirection(at: recognizer.location(in: self)) == streak.direction {
            fastSeek(streak.direction)
        } else if isSelected && playArea.contains(location) {
            playPauseAction()
        } else {
            delegate?.didTap(isSelected: isSelected)
        }
    }

    @objc
    func doubleTapAction(recognizer: UITapGestureRecognizer) {
        guard let direction = seekDirection(at: recognizer.location(in: self)) else {
            return
        }
        if let streak = activeSeekStreak, streak.direction == direction {
            // Double tap inside a series counts as two more steps.
            fastSeek(direction)
        }
        fastSeek(direction)
    }

    var activeSeekStreak: SeekStreak? {
        guard let streak = seekStreak,
              Date().timeIntervalSince(streak.lastTap) < FastSeek.streakWindow else {
            return nil
        }
        return streak
    }

    func seekDirection(at location: CGPoint) -> SeekDirection? {
        let deadZone = max(24, config.playBackgroundRadius)
        if location.x > bounds.midX + deadZone {
            return .forward
        } else if location.x < bounds.midX - deadZone {
            return .backward
        }
        return nil
    }

    func fastSeek(_ direction: SeekDirection) {
        var streak = activeSeekStreak.flatMap { $0.direction == direction ? $0 : nil }
            ?? SeekStreak(direction: direction, total: 0, lastTap: Date())
        streak.total += FastSeek.step
        streak.lastTap = Date()
        seekStreak = streak

        let seconds = Int(streak.total)
        switch direction {
        case .forward:
            delegate?.didFastForward()
            backwardFeedback.hide()
            forwardFeedback.show(totalSeconds: seconds)
        case .backward:
            delegate?.didFastBackward()
            forwardFeedback.hide()
            backwardFeedback.show(totalSeconds: seconds)
        }
    }
}

extension PlayerOverlayView: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard gestureRecognizer === singleTap || gestureRecognizer === doubleTap else {
            return true
        }
        delegate?.didTouchVideo()
        // While the chrome is faded out the button cannot be hit, so a center tap must reveal it.
        guard contentView.alpha > 0.01 else {
            return true
        }
        let point = touch.location(in: playPauseView)
        return !playPauseView.bounds.contains(point)
    }
}

/// Top or bottom darkening shown with the controls. Same stops as the Android mobile chrome.
final class ChromeGradientBand: UIView {

    enum Edge {
        case top
        case bottom
    }

    private let gradient = CAGradientLayer()

    init(edge: Edge) {
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        backgroundColor = .clear
        let solid = UIColor.black.withAlphaComponent(163.0 / 255.0).cgColor
        let clear = UIColor.clear.cgColor
        gradient.colors = edge == .top ? [solid, clear] : [clear, solid]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        layer.addSublayer(gradient)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }
}
