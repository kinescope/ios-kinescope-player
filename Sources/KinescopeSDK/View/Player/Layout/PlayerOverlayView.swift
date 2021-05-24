//
//  PlayerOverlayView.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 30.03.2021.
//

import UIKit

/// Configurable player overlay view. Handles play/pause and fast rewind taps&
class PlayerOverlayView: UIControl {

    // MARK: - Properties

    let playPauseImageView = UIImageView()
    let fastForwardImageView = UIImageView()
    let fastBackwardImageView = UIImageView()
    private let contentView = UIView()
    private let config: KinescopePlayerOverlayConfiguration
    private weak var delegate: PlayerOverlayViewDelegate?
    private var isRewind = false
    var playPauseReplayState: PlayPauseReplayState = .play {
        didSet {
            playPauseImageView.isHidden = false
            switch playPauseReplayState {
            case .play:
                playPauseImageView.image = config.playImage
            case .pause:
                playPauseImageView.image = config.pauseImage
            case .replay:
                playPauseImageView.image = config.replayImage
            case .loading:
                playPauseImageView.isHidden = true
            }
        }
    }
    var duration: TimeInterval {
        return config.duration
    }

    // Taps

    private var activeTaps = 0
    private let tapDebouncer = Debouncer(timeInterval: 0.2)
    private var lastTapLocation: CGPoint? = .zero
    private var previousTapLocation: CGPoint? = .zero

    // MARK: - Lifecycle

    init(config: KinescopePlayerOverlayConfiguration, delegate: PlayerOverlayViewDelegate? = nil) {
        self.config = config
        self.delegate = delegate
        super.init(frame: .zero)
        self.setupInitialState()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UIControl

    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                let alpha: CGFloat = self.isSelected ? 1.0 : .zero
                self.contentView.alpha = alpha
                self.delegate?.didAlphaChanged(alpha: alpha)
            }
        }
    }
}

// MARK: - Private

private extension PlayerOverlayView {
    func setupInitialState() {
        isSelected = false

        addGestureRecognizers()
        configureContentView()
    }

    func configureContentView() {
        contentView.isUserInteractionEnabled = false
        contentView.backgroundColor = config.backgroundColor
        addSubview(contentView)
        stretch(view: contentView)

        configurePlayPauseImageView()
        configureFastForwardImageView()
        configureFastBackwardImageView()
    }

    func configurePlayPauseImageView() {
        playPauseReplayState = .play
        contentView.addSubview(playPauseImageView)
        contentView.centerChild(view: playPauseImageView)
    }

    func configureFastForwardImageView() {
        fastForwardImageView.image = config.fastForwardImage
        fastForwardImageView.tintColor = .white
        fastForwardImageView.alpha = .zero
        addSubview(fastForwardImageView)
        rightCenterChild(view: fastForwardImageView)
    }

    func configureFastBackwardImageView() {
        fastBackwardImageView.image = config.fastBackwardImage
        fastBackwardImageView.tintColor = .white
        fastBackwardImageView.alpha = .zero
        addSubview(fastBackwardImageView)
        leftCenterChild(view: fastBackwardImageView)
    }

    func addGestureRecognizers() {
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                action: #selector(tapAction))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        addGestureRecognizer(singleTapGestureRecognizer)
    }

}

// MARK: - Actions

private extension PlayerOverlayView {

    @objc
    func tapAction(recognizer: UITapGestureRecognizer) {
        if activeTaps == 0 {
            tapDebouncer.handler = { [weak self] in
                guard let self = self else {
                    return
                }
                if self.activeTaps == 1 {
                    self.singleTapAction()
                }
                self.activeTaps = 0
                self.lastTapLocation = nil
                self.previousTapLocation = nil
            }
        } else {
            doubleTapAction()
        }
        previousTapLocation = lastTapLocation
        lastTapLocation = recognizer.location(in: contentView)
        activeTaps += 1
        tapDebouncer.renewInterval()
    }

    func singleTapAction() {
        guard let lastTapLocation = lastTapLocation else {
            return
        }

        if isSelected && playPauseImageView.frame.contains(lastTapLocation) {
            delegate?.didPlayPause()
        } else {
            isRewind = false
            delegate?.didTap(isSelected: isSelected)
        }
    }

    func doubleTapAction() {
        guard let lastTapLocation = lastTapLocation else {
            return
        }
        isRewind = true

        let rightFrame = CGRect(x: contentView.center.x + 24.0,
                                y: .zero,
                                width: contentView.bounds.width - contentView.center.x + 24.0,
                                height: contentView.bounds.height)

        let leftFrame = CGRect(x: .zero,
                               y: .zero,
                               width: contentView.bounds.width - contentView.center.x - 24.0,
                               height: contentView.bounds.height)

        if rightFrame.contains(lastTapLocation) {
            if let previousTapLocation = previousTapLocation, !rightFrame.contains(previousTapLocation) {
                return
            }

            delegate?.didFastForward(sec: config.fastForward.rawValue)

            fastForwardImageView.alpha = 1.0
            UIView.animate(
                withDuration: 0.6,
                animations: {
                    self.fastForwardImageView.transform = .init(scaleX: 2.0, y: 2.0)
                    self.fastForwardImageView.alpha = .zero
                },
                completion: { _ in
                    self.fastForwardImageView.alpha = .zero
                    self.fastForwardImageView.transform = .identity
                }
            )
        } else if leftFrame.contains(lastTapLocation) {
            if let previousTapLocation = previousTapLocation, !leftFrame.contains(previousTapLocation) {
                return
            }

            delegate?.didFastBackward(sec: config.fastBackward.rawValue)

            fastBackwardImageView.alpha = 1.0
            UIView.animate(
                withDuration: 0.6,
                animations: {
                    self.fastBackwardImageView.transform = .init(scaleX: 2.0, y: 2.0)
                    self.fastBackwardImageView.alpha = .zero
                },
                completion: { _ in
                    self.fastBackwardImageView.alpha = .zero
                    self.fastBackwardImageView.transform = .identity
                }
            )
        }
    }
}
