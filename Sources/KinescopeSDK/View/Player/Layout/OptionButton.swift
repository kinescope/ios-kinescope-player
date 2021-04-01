//
//  OptionButton.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 01.04.2021.
//

import UIKit

final class OptionButton: UIButton {

    let option: KinescopePlayerOption

    init(option: KinescopePlayerOption) {
        self.option = option
        super.init(frame: .zero)
        setupInitialState()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Private

private extension OptionButton {

    func setupInitialState() {
        setImage(UIImage.image(named: option.rawValue), for: .normal)
    }

}
