//
//  SideMenuBar.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 02.04.2021.
//
// swiftlint:disable implicitly_unwrapped_optional

import UIKit

protocol SideMenuBarDelegate: AnyObject {
    func closeTapped()
    func backTapped()
    func downloadAllTapped(for title: String)
}

final class SideMenuBar: UIView {

    struct Model {
        let title: String
        let isRoot: Bool
        let isDownloadable: Bool
        let showsCloseButton: Bool
    }

    // MARK: - Views

    private weak var backButton: UIButton!
    private weak var titleView: UILabel!
    private weak var closeButton: UIButton!
    private weak var downloadAllButton: UIButton!

    // MARK: - Properties

    private let config: KinescopeSideMenuBarConfiguration
    private let model: Model

    weak var delegate: SideMenuBarDelegate?

    func setDisplayedTitle(_ title: String) {
        titleView.text = title
    }

    // MARK: - Init

    init(config: KinescopeSideMenuBarConfiguration, model: Model) {
        self.config = config
        self.model = model
        super.init(frame: .zero)
        setupInitialState()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        .init(width: .greatestFiniteMagnitude, height: config.preferedHeight)
    }

}

// MARK: - Actions

private extension SideMenuBar {

    @objc
    func onCloseTapped() {
        delegate?.closeTapped()
    }

    @objc
    func onBackTapped() {
        delegate?.backTapped()
    }

    @objc
    func onDownloadAllTapped() {
        delegate?.downloadAllTapped(for: model.title)
    }

}

// MARK: - Private

private extension SideMenuBar {

    func setupInitialState() {

        configureTitle()
        titleView.translatesAutoresizingMaskIntoConstraints = false
        if model.showsCloseButton {
            configureCloseButton()
        }

        let titleTrailing = model.showsCloseButton
            ? titleView.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -4)
            : titleView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)

        if model.isRoot {
            NSLayoutConstraint.activate([
                titleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                titleTrailing,
                titleView.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        } else {
            configureBackButton()
            titleView.isUserInteractionEnabled = true
            titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onBackTapped)))

            NSLayoutConstraint.activate([
                backButton.centerYAnchor.constraint(equalTo: centerYAnchor),
                backButton.leadingAnchor.constraint(equalTo: leadingAnchor),
                titleView.leadingAnchor.constraint(equalTo: backButton.trailingAnchor),
                titleTrailing,
                titleView.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        }

        if model.showsCloseButton {
            NSLayoutConstraint.activate([
                closeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
                closeButton.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        }

        if model.isDownloadable {
            configureDownloadButton()
            let downloadTrailing = model.showsCloseButton
                ? downloadAllButton.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -4)
                : downloadAllButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
            NSLayoutConstraint.activate([
                downloadAllButton.centerYAnchor.constraint(equalTo: centerYAnchor),
                downloadTrailing
            ])
        }

    }

    func configureTitle() {
        let label = UILabel()
        label.font = config.titleFont
        label.textColor = config.titleColor
        label.text = model.title

        addSubview(label)

        self.titleView = label
    }

    func configureCloseButton() {
        let button = makeBarButton(imageName: "close", action: #selector(onCloseTapped))
        self.closeButton = button
    }

    func configureBackButton() {
        let button = makeBarButton(imageName: "back", action: #selector(onBackTapped))
        self.backButton = button
    }

    /// Icon stays `iconSize`, but the control fills the bar so the tap lands beside the glyph too.
    func makeBarButton(imageName: String, action: Selector) -> UIButton {
        let button = UIButton()
        button.setImage(.image(named: imageName), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: max(config.iconSize, 44)),
            button.heightAnchor.constraint(equalTo: heightAnchor)
        ])
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    func configureDownloadButton() {
        let button = UIButton()
        button.setTitle(L10n.Player.downloadAll, for: .normal)
        button.titleLabel?.font = config.downloadAllFont
        button.setTitleColor(config.downloadAllColor, for: .normal)
        button.setTitleColor(config.downloadAllHighlightedColor, for: .highlighted)
        button.translatesAutoresizingMaskIntoConstraints = false

        addSubview(button)
        button.sizeToFit()
        button.addTarget(self, action: #selector(onDownloadAllTapped), for: .touchUpInside)

        self.downloadAllButton = button
    }

}
