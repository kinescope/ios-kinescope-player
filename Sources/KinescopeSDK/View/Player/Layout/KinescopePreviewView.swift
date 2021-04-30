//
//  PreviewView.swift
//  KinescopeSDK
//
//  Created by Никита Гагаринов on 28.04.2021.
//

import UIKit

public protocol KinescopePreviewViewDelegate: class {
    func didTap()
}

/// Model for displaying preview view
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

/// Preview View with video title, description, duration, banner and play image
public final class KinescopePreviewView: UIView {

    // MARK: - Public Properties

    public private(set) var previewImageView = UIImageView()
    public var config: KinescopePreviewViewConfiguration = .default
    public weak var delegate: KinescopePreviewViewDelegate?

    // MARK: - Private Properties

    private let playImageView = UIImageView()
    private let nameView: VideoNameView
    private let durationLabel = UILabel()
    private let formatter = DateFormatter()
    private var durationLabelWidthConstraint = NSLayoutConstraint()

    // MARK: - Init

    public init(config: KinescopePreviewViewConfiguration, delegate: KinescopePreviewViewDelegate? = nil) {
        self.config = config
        self.nameView = VideoNameView(config: config.nameConfiguration)
        self.delegate = delegate
        super.init(frame: .zero)
        configureAppearence()
    }

    public required init?(coder: NSCoder) {
        self.nameView = VideoNameView(config: config.nameConfiguration)
        super.init(coder: coder)
        configureAppearence()
    }

    // MARK: - Public Methods

    public func setPreview(with model: KinescopePreviewModel) {
        nameView.set(title: model.title, subtitle: model.subtitle)
        let durationText = getDurationText(from: model.duration)
        let fontAttributes = [NSAttributedString.Key.font: config.durationFont]
        let durationWidth = (durationText as NSString).size(withAttributes: fontAttributes).width
        durationLabel.text = durationText
        durationLabelWidthConstraint.constant = durationWidth + 8
    }

}

// MARK: - Private Methods

private extension KinescopePreviewView {

    func configureAppearence() {
        configurePreviewImageView()
        configurePlayImageView()
        configureNameView()
        configureDurationLabel()
        addGestureRecognizers()
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
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(durationLabel)
        durationLabel.font = config.durationFont
        durationLabel.textColor = config.durationColor
        durationLabel.textAlignment = .center
        durationLabel.backgroundColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 0.8)
        durationLabel.layer.cornerRadius = 4
        durationLabel.layer.masksToBounds = true

        let durationLabelWidthConstraint = durationLabel.widthAnchor.constraint(equalToConstant: 0)
        self.durationLabelWidthConstraint = durationLabelWidthConstraint

        NSLayoutConstraint.activate([
            durationLabel.topAnchor.constraint(equalTo: playImageView.bottomAnchor, constant: 4),
            durationLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            self.durationLabelWidthConstraint
        ])
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
