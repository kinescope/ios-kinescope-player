//
//  PlayerControlView.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//

import UIKit

class PlayerControlView: UIControl {

    init(config: KinescopeControlPanelConfiguration) {
        super.init(frame: .zero)
        setupInitialState(with: config)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Private

private extension PlayerControlView {

    func setupInitialState(with config: KinescopeControlPanelConfiguration) {
        // configure control panel
    }

}
