//
//  PlayerOverlayView.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 30.03.2021.
//

import UIKit

protocol PlayerOverlayInput: VideoNameInput {
}

class PlayerOverlayView: UIControl {

    // MARK: - Properties

    let playPauseImageView = UIImageView()
    let nameView: VideoNameView
    private let contentView = UIView()
    private let config: KinescopePlayerOverlayConfiguration
    private weak var delegate: PlayerOverlayViewDelegate?
    private var isPlaying = false
    private var isEndPlaying = false

    // MARK: - Lifecycle

    init(config: KinescopePlayerOverlayConfiguration, delegate: PlayerOverlayViewDelegate? = nil) {
        self.config = config
        self.delegate = delegate
        self.nameView = VideoNameView(config: config.nameConfiguration)
        super.init(frame: .zero)
        self.setupInitialState()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEndPlayingAction),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: nil)
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
            isSelected ? setSelectedState() : setDeselectedState()
        }
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)

        guard
            let location = touch?.location(in: contentView)
        else {
            return
        }

        if isSelected && playPauseImageView.frame.contains(location) {
            playPauseAction()
        } else {
            isSelected.toggle()
        }
    }
}

// MARK: - PlayerOverlayInput

extension PlayerOverlayView: PlayerOverlayInput {
    func set(title: String, subtitle: String) {
        nameView.set(title: title, subtitle: subtitle)
    }
}

// MARK: - Private

private extension PlayerOverlayView {
    func setupInitialState() {
        isSelected = true
        isPlaying = true

        configureContentView()
    }

    func configureContentView() {
        contentView.isUserInteractionEnabled = false
        contentView.backgroundColor = config.backgroundColor
        addSubview(contentView)
        stretch(view: contentView)
        configureImageView()
        configureNameView()
    }

    func configureImageView() {
        playPauseImageView.image = isPlaying ? config.pauseImage : config.playImage
        contentView.addSubview(playPauseImageView)
        contentView.centerChild(view: playPauseImageView)
    }

    func configureNameView() {
        contentView.addSubview(nameView)
        contentView.topChild(view: nameView)
    }

    func setSelectedState() {
        UIView.animate(withDuration: 0.3) {
            self.contentView.alpha = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + config.animationDuration) {
            self.isSelected = false
        }
    }

    func setDeselectedState() {
        UIView.animate(withDuration: 0.3) {
            self.contentView.alpha = .zero
        }
    }
}

// MARK: - Actions

private extension PlayerOverlayView {
    @objc
    func playPauseAction() {
        isPlaying.toggle()

        if isPlaying {
            playPauseImageView.image = config.pauseImage
            delegate?.didPlay(videoEnded: isEndPlaying)
        } else {
            playPauseImageView.image = config.playImage
            delegate?.didPause()
        }

        isEndPlaying = false
    }

    @objc
    func didEndPlayingAction() {
        isEndPlaying = true
        isPlaying = false
        playPauseImageView.image = config.playImage
    }
}
