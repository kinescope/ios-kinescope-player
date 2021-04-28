//
//  PlayerOverlayView.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 30.03.2021.
//

import UIKit

class PlayerOverlayView: UIControl {

    // MARK: - Properties

    let playPauseImageView = UIImageView()
    let fastForwardImageView = UIImageView()
    let fastBackwardImageView = UIImageView()
    let nameView: VideoNameView
    private let contentView = UIView()
    private let config: KinescopePlayerOverlayConfiguration
    private weak var delegate: PlayerOverlayViewDelegate?
    private var isRewind = false
    var playPauseReplayState: PlayPauseReplayState = .play {
        didSet {
            switch playPauseReplayState {
            case .play:
                playPauseImageView.image = config.playImage
            case .pause:
                playPauseImageView.image = config.pauseImage
            case .replay:
                playPauseImageView.image = config.replayImage
            }
        }
    }
    var duration: TimeInterval {
        return config.duration
    }

    // MARK: - Lifecycle

    init(config: KinescopePlayerOverlayConfiguration, delegate: PlayerOverlayViewDelegate? = nil) {
        self.config = config
        self.delegate = delegate
        self.nameView = VideoNameView(config: config.nameConfiguration)
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
                self.contentView.alpha = self.isSelected ? 1.0 : .zero
            }
        }
    }
}

// MARK: - VideoNameInput

extension PlayerOverlayView: VideoNameInput {
    func set(title: String, subtitle: String) {
        nameView.set(title: title, subtitle: subtitle)
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

        configureNameView()
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
        fastForwardImageView.alpha = .zero
        addSubview(fastForwardImageView)
        rightCenterChild(view: fastForwardImageView)
    }

    func configureFastBackwardImageView() {
        fastBackwardImageView.image = config.fastBackwardImage
        fastBackwardImageView.alpha = .zero
        addSubview(fastBackwardImageView)
        leftCenterChild(view: fastBackwardImageView)
    }

    func configureNameView() {
        contentView.addSubview(nameView)
        contentView.topChildWithSafeArea(view: nameView)
    }

    func addGestureRecognizers() {
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                             action: #selector(singleTapAction))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        addGestureRecognizer(singleTapGestureRecognizer)

        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                             action: #selector(doubleTapAction))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapGestureRecognizer)

        singleTapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
    }

}

// MARK: - Actions

private extension PlayerOverlayView {
    @objc
    func playPauseAction() {
        delegate?.didPlayPause()
    }

    @objc
    func singleTapAction(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: contentView)

        if isSelected && playPauseImageView.frame.contains(location) {
            playPauseAction()
        } else {
            isRewind = false
            delegate?.didTap(isSelected: isSelected)
        }
    }

    @objc
    func doubleTapAction(recognizer: UITapGestureRecognizer) {
        isRewind = true

        let location = recognizer.location(in: self)
        let rightFrame = CGRect(x: contentView.center.x + 24.0,
                                y: .zero,
                                width: contentView.bounds.width - contentView.center.x + 24.0,
                                height: contentView.bounds.height)

        let leftFrame = CGRect(x: .zero,
                               y: .zero,
                               width: contentView.bounds.width - contentView.center.x - 24.0,
                               height: contentView.bounds.height)

        if rightFrame.contains(location) {
            delegate?.didFastForward()

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
        } else if leftFrame.contains(location) {
            delegate?.didFastBackward()

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
