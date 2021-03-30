//
//  PlayerOverlayView.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 30.03.2021.
//

import UIKit

class PlayerOverlayView: UIControl {

    let imageView: UIImageView = UIImageView()

    init(config: KinescopePlayerOverlayConfiguration) {
        super.init(frame: .zero)
        setupInitialState(with: config)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Private

private extension PlayerOverlayView {

    func setupInitialState(with config: KinescopePlayerOverlayConfiguration) {
        // configure overlay
        configureImageView()
    }

    func configureImageView() {
        addSubview(imageView)
        centerChild(view: imageView)
        imageView.isHidden = true
    }

}
