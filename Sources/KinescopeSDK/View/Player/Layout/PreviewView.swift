//
//  PreviewView.swift
//  KinescopeSDK
//
//  Created by Никита Гагаринов on 28.04.2021.
//

import UIKit

protocol PreviewViewDelegate: class {
    func didTap()
}

/// Model for displaying preview
public struct KinescopePreviewModel {
    let title: String
    let subtitle: String
    let duration: TimeInterval

    /// - parameter title: Title of video
    /// - parameter subtitle: Description of video
    /// - parameter duration: Full duration of video
    public init(title: String, subtitle: String, duration: TimeInterval) {
        self.title = title
        self.subtitle = subtitle
        self.duration = duration
    }

    public init(from video: KinescopeVideo) {
        self.title = video.title
        self.subtitle = video.description
        self.duration = video.duration
    }
}

public final class PreviewView: UIView {

    // MARK: - Public Properties

    public private(set) var previewImageView = UIImageView()

    // MARK: - Private Properties

    private let config: KinescopePreviewViewConfiguration
    private weak var delegate: PreviewViewDelegate?

    private let playImageView = UIImageView()
    private let nameView: VideoNameView
    private let durationLabel = UILabel()
    private let formatter = DateFormatter()

    // MARK: - Init

    init(config: KinescopePreviewViewConfiguration, delegate: PreviewViewDelegate) {
        self.config = config
        self.nameView = VideoNameView(config: config.nameConfiguration)
        self.delegate = delegate
        super.init(frame: .zero)
        configureAppearence()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    public func setPreview(with model: KinescopePreviewModel) {
        nameView.set(title: model.title, subtitle: model.subtitle)
        durationLabel.text = getDurationText(from: model.duration)
    }

}

// MARK: - Private Methods

private extension PreviewView {

    func configureAppearence() {
        configurePreviewImageView()
        configurePlayImageView()
        configureNameView()
    }

    func configurePreviewImageView() {
        addSubview(previewImageView)
        stretch(view: previewImageView)
    }
    
    func configurePlayImageView() {
        playImageView.image = config.playImage
        addSubview(playImageView)
        centerChild(view: playImageView)
    }

    func configureNameView() {
        addSubview(nameView)
        topChildWithSafeArea(view: nameView)
    }

    func configureDurationLabel() {
        durationLabel.font = config.durationFont
        durationLabel.textColor = config.durationColor
    }

    func addGestureRecognizers() {
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                             action: #selector(playAction))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        addGestureRecognizer(singleTapGestureRecognizer)
    }

    func getDurationText(from time: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: time)
        let duration = KinescopeVideoDuration.from(raw: time)
        formatter.dateFormat = duration.rawValue
        return formatter.string(from: date)
    }

    @objc
    func playAction() {
        delegate?.didTap()
    }

}
