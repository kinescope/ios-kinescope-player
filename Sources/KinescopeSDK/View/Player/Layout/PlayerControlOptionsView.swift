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

    private let stackView = UIStackView()

    private let config: KinescopePlayerOptionsConfiguration
    private(set) var options: [KinescopePlayerOption] = []
    private var isSubtitleOn = false
    
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
        .init(width: config.iconSize * 2, height: config.iconSize)
    }

    var isExpanded: Bool = false {
        didSet {
            fillStack(with: options, expanded: isExpanded)
        }
    }

}

// MARK: - Input

extension PlayerControlOptionsView: PlayerControlOptionsInput {

    func getCustomOptionView(by id: AnyHashable) -> UIView? {
        let buttonTag = customOptionsTagMap[id]
        return stackView.arrangedSubviews
            .first(where: { $0.tag == buttonTag })
    }

    func set(options: [KinescopePlayerOption]) {
        self.options = options
        self.isExpanded = false

        fillStack(with: options, expanded: isExpanded)
    }

    func set(subtitleOn: Bool) {
        self.isSubtitleOn = subtitleOn

        let button = stackView.arrangedSubviews
            .compactMap { $0 as? OptionButton }
            .first { $0.option == .subtitles }

        button?.isSelected = subtitleOn
    }

}

// MARK: - Private

private extension PlayerControlOptionsView {

    func setupInitialState(with config: KinescopePlayerOptionsConfiguration) {

        configureStack()
    }

    func configureStack() {
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .trailing
        stackView.distribution = .fill
        stackView.backgroundColor = .clear

        addSubview(stackView)
        stretch(view: stackView)
    }

    func createButton(from option: KinescopePlayerOption, at index: Int) -> UIView {
        switch option {
        case .airPlay:
            let button = AirPlayOptionControl()
            button.tintColor = config.normalColor
            button.squareSize(with: config.iconSize)
            button.tag = index
            return button
        default:
            let button = OptionButton(option: option)

            if let optionId = option.optionId {
                customOptionsTagMap[optionId] = index
            }
            
            button.tag = index
            button.tintColor = config.normalColor
            button.squareSize(with: config.iconSize)

            button.addTarget(nil, action: #selector(buttonTapped(sender:)), for: .touchUpInside)

            return button
        }
    }

    func fillStack(with options: [KinescopePlayerOption], expanded: Bool) {
        guard !options.isEmpty else {
            return
        }

        clearStack()

        let filteredOptions = expanded
            ? options
            : Array(options.dropFirst(options.count - 2))

        filteredOptions
            .enumerated()
            .map { index, option in
                createButton(from: option, at: index)
            }
            .forEach { [weak self] button in
                self?.stackView.addArrangedSubview(button)
            }

        set(subtitleOn: isSubtitleOn)
    }

    func clearStack() {
        stackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
            stackView.removeArrangedSubview($0)
        }
    }

    @objc
    func buttonTapped(sender: OptionButton) {
        let option = sender.option

        Kinescope.shared.logger?.log(message: "Options menu button tapped: \(option)",
                                     level: KinescopeLoggerLevel.player)

        output?.didSelect(option: option)
    }

}
