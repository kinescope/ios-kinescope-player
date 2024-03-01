//
//  PlayerOverlayView.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 30.03.2021.
//

import UIKit

protocol PlayerOverlayInput: VideoNameInput {
    func set(playing: Bool)
}

class PlayerOverlayView: UIControl {

    // MARK: - Properties

    let playPauseImageView = UIImageView()
    let fastForwardImageView = UIImageView()
    let fastBackwardImageView = UIImageView()
    let nameView: VideoNameView
    let liveIndicator: LiveIndicatorView
    private let contentView = UIView()
    private let config: KinescopePlayerOverlayConfiguration
    private weak var delegate: PlayerOverlayViewDelegate?
    private var isPlaying = false
    private var isRewind = false
    var duration: TimeInterval {
        return config.duration
    }

    // MARK: - Lifecycle

    init(config: KinescopePlayerOverlayConfiguration, delegate: PlayerOverlayViewDelegate? = nil) {
        self.config = config
        self.delegate = delegate
        self.nameView = VideoNameView(config: config.nameConfiguration)
        self.liveIndicator = LiveIndicatorView(config: config.liveConfiguration)
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

// MARK: - PlayerOverlayInput

extension PlayerOverlayView: PlayerOverlayInput {
    func set(title: String, subtitle: String) {
        nameView.set(title: title, subtitle: subtitle)
    }

    func set(playing: Bool) {
        self.isPlaying = playing
        playPauseImageView.image = playing ? config.pauseImage : config.playImage
    }

    func set(live: Bool?) {
        if let live {
            liveIndicator.isHidden = false
            liveIndicator.set(animated: live)
        } else {
            liveIndicator.isHidden = true
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

        configureNameView()
        configureLiveIndicator()
        configurePlayPauseImageView()
        configureFastForwardImageView()
        configureFastBackwardImageView()
    }

    func configurePlayPauseImageView() {
        playPauseImageView.image = isPlaying ? config.pauseImage : config.playImage
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
    
    func configureLiveIndicator() {
        contentView.addSubview(liveIndicator)
        contentView.topTrailingChildWithSafeArea(view: liveIndicator)
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
        isPlaying.toggle()

        if isPlaying {
            playPauseImageView.image = config.pauseImage
            delegate?.didPlay()
        } else {
            playPauseImageView.image = config.playImage
            delegate?.didPause()
        }
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
