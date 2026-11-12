//
//  PlayerControlOptionsView.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 31.03.2021.
//

import UIKit

protocol PlayerControlOptionsInput {

    func getCustomOptionView(by id: AnyHashable) -> UIView?

    /// Set available options
    ///
    /// - parameter options: Set of option
    func set(options: [KinescopePlayerOption])
    func set(subtitleOn: Bool)
    func set(fullscreenOn: Bool)
    func set(settingsBadgeFor height: CGFloat)
}

protocol PlayerControlOptionsOutput: AnyObject {

    /// Callback of user initiated expand action. Called on three dots tapped.
    ///
    /// - parameter expanded: Value of `true` when all options expanded. `false` when visible only `2` options.
    func didOptions(expanded: Bool)

    /// Callback of user initiated selection of option. Called on button tapped.
    ///
    /// - parameter option: Option assosiated with button which were tapped
    func didSelect(option: KinescopePlayerOption)

}

class PlayerControlOptionsView: UIControl {

    private enum Constants {
        /// Wider than the 24 pt glyph so a tap next to the icon still hits the button.
        static let buttonSide: CGFloat = 44
    }

    private let row = UIView()
    private var buttons: [UIView] = []
    private var buttonWidths: [NSLayoutConstraint] = []

    private let config: KinescopePlayerOptionsConfiguration
    private(set) var options: [KinescopePlayerOption] = []
    private var isSubtitleOn = false
    private var isFullscreenOn = false
    private var settingsIconName = "settings"
    private var extraWidths: [NSLayoutConstraint] = []
    
    private var customOptionsTagMap: [AnyHashable: Int] = [:]

    weak var output: PlayerControlOptionsOutput?

    init(config: KinescopePlayerOptionsConfiguration) {
        self.config = config
        super.init(frame: .zero)
        setupInitialState(with: config)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: laidOutWidth, height: Constants.buttonSide)
    }

    /// Width the strip occupies right now, including buttons that are still collapsed to zero.
    var laidOutWidth: CGFloat {
        buttonWidths.reduce(0) { $0 + $1.constant }
    }

    var isExpanded: Bool = false

}

// MARK: - Input

extension PlayerControlOptionsView: PlayerControlOptionsInput {

    func getCustomOptionView(by id: AnyHashable) -> UIView? {
        let buttonTag = customOptionsTagMap[id]
        return buttons.first(where: { $0.tag == buttonTag })
    }

    func set(options: [KinescopePlayerOption]) {
        self.options = options
        self.isExpanded = false

        fillStack(with: options, expanded: isExpanded)
    }

    func set(subtitleOn: Bool) {
        self.isSubtitleOn = subtitleOn
        button(for: .subtitles)?.isSelected = subtitleOn
    }

    func set(fullscreenOn: Bool) {
        self.isFullscreenOn = fullscreenOn
        button(for: .fullscreen)?.isSelected = fullscreenOn
    }

    /// Show HD / 4K badge on settings icon depending on playing video height.
    func set(settingsBadgeFor height: CGFloat) {
        let name: String
        switch height {
        case 2160...:
            name = "settings4K"
        case 720...:
            // Same cutoff as the quality list: 720, 1080 and 1440 are HD.
            name = "settingsHD"
        default:
            name = "settings"
        }
        settingsIconName = name
        let image = UIImage.image(named: name).withRenderingMode(.alwaysOriginal)
        button(for: .settings)?.setImage(image, for: .normal)
        button(for: .settings)?.setImage(image, for: .highlighted)
        button(for: .settings)?.setImage(image, for: .selected)
    }

    func setExtraWidths(revealed: Bool) {
        let side = revealed ? Constants.buttonSide : 0
        extraWidths.forEach { $0.constant = side }
        invalidateIntrinsicContentSize()
    }

    func setExtraAlpha(revealed: Bool) {
        extraWidths.forEach { ($0.firstItem as? UIView)?.alpha = revealed ? 1 : 0 }
    }

}

// MARK: - Private

private extension PlayerControlOptionsView {

    func setupInitialState(with config: KinescopePlayerOptionsConfiguration) {

        configureStack()
    }

    func configureStack() {
        row.backgroundColor = .clear
        row.clipsToBounds = true
        addSubview(row)
        stretch(view: row)
    }

    func createButton(from option: KinescopePlayerOption,
                      at index: Int,
                      width: CGFloat = Constants.buttonSide) -> (UIView, NSLayoutConstraint) {
        switch option {
        case .airPlay:
            let button = AirPlayOptionControl()
            button.tintColor = config.normalColor
            button.clipsToBounds = true
            button.tag = index
            return (button, pin(button, width: width))
        default:
            let button = OptionButton(option: option)

            if let optionId = option.optionId {
                customOptionsTagMap[optionId] = index
            }
            
            button.tag = index
            button.tintColor = config.normalColor
            button.clipsToBounds = true
            // A nil target starts at the first responder. Custom Player becomes that
            // responder for keyboard shortcuts, so the tap never reached this view.
            button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)

            return (button, pin(button, width: width))
        }
    }

    func fillStack(with options: [KinescopePlayerOption], expanded: Bool) {
        guard !options.isEmpty else {
            return
        }

        clearStack()

        let hiddenCount = expanded ? 0 : max(0, options.count - min(2, options.count))
        var anchor = row.trailingAnchor
        for (index, option) in options.enumerated().reversed() {
            let collapsed = index < hiddenCount
            let (button, width) = createButton(from: option, at: index, width: collapsed ? 0 : Constants.buttonSide)
            button.alpha = collapsed ? 0 : 1
            row.addSubview(button)
            NSLayoutConstraint.activate([
                button.trailingAnchor.constraint(equalTo: anchor),
                button.centerYAnchor.constraint(equalTo: row.centerYAnchor),
                button.heightAnchor.constraint(equalToConstant: Constants.buttonSide)
            ])
            if collapsed {
                extraWidths.append(width)
            }
            buttons.insert(button, at: 0)
            buttonWidths.insert(width, at: 0)
            anchor = button.leadingAnchor
        }

        set(subtitleOn: isSubtitleOn)
        set(fullscreenOn: isFullscreenOn)
        let settingsImage = UIImage.image(named: settingsIconName).withRenderingMode(.alwaysOriginal)
        button(for: .settings)?.setImage(settingsImage, for: .normal)
        button(for: .settings)?.setImage(settingsImage, for: .selected)
        invalidateIntrinsicContentSize()
    }

    func pin(_ button: UIView, width: CGFloat) -> NSLayoutConstraint {
        button.translatesAutoresizingMaskIntoConstraints = false
        let constraint = button.widthAnchor.constraint(equalToConstant: width)
        constraint.isActive = true
        return constraint
    }

    func button(for option: KinescopePlayerOption) -> OptionButton? {
        buttons
            .compactMap { $0 as? OptionButton }
            .first { $0.option == option }
    }

    func clearStack() {
        extraWidths.removeAll()
        buttonWidths.removeAll()
        buttons.forEach { $0.removeFromSuperview() }
        buttons.removeAll()
    }

    @objc
    func buttonTapped(sender: OptionButton) {
        let option = sender.option

        Kinescope.shared.logger?.log(message: "Options menu button tapped: \(option)",
                                     level: KinescopeLoggerLevel.player)

        output?.didSelect(option: option)
    }

}
