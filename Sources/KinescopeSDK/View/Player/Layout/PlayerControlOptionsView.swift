//
//  PlayerControlOptionsView.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 31.03.2021.
//

import UIKit

protocol PlayerControlOptionsInput {

    /// Set available options
    ///
    /// - Warning: Will be replaced with enum in KIN-51
    /// - parameter options: Set of option
    func set(options: [String])
}

protocol PlayerControlOptionsOutput: class {

    /// Callback of user initiated expand action. Called on three dots tapped.
    ///
    /// - parameter isExpanded: Value of `true` when all options expanded. `false` when visible only `2` options.
    func didOptions(isExpanded: Bool)

}

class PlayerControlOptionsView: UIControl {

    private let config: KinescopePlayerOptionsConfiguration

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

}

// MARK: - Private

private extension PlayerControlOptionsView {

    func setupInitialState(with config: KinescopePlayerOptionsConfiguration) {
        // configure timeline

        backgroundColor = config.normalColor
    }

}
