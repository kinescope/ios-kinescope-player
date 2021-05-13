//
//  PlayerShadowOverlayView.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 16.04.2021.
//

import UIKit

protocol ShadowOverlayDelegate: AnyObject {
    /// Tap callback
    func onTap()
}

class PlayerShadowOverlayView: UIView {

    // MARK: - Private Properties

    private let config: KinescopePlayerShadowOverlayConfiguration
    private weak var delegate: ShadowOverlayDelegate?

    // MARK: - Init

    init(config: KinescopePlayerShadowOverlayConfiguration, delegate: ShadowOverlayDelegate? = nil) {
        self.config = config
        self.delegate = delegate
        super.init(frame: .zero)
        setupInitialState(with: config)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Private

private extension PlayerShadowOverlayView {

    func setupInitialState(with config: KinescopePlayerShadowOverlayConfiguration) {
        backgroundColor = config.color

        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                action: #selector(tap))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        addGestureRecognizer(singleTapGestureRecognizer)
    }

    @objc func tap() {
        delegate?.onTap()
    }

}
