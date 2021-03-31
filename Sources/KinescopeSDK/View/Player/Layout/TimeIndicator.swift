//
//  TimeIndicator.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 31.03.2021.
//

import UIKit

protocol TimeIndicatorInput {

    /// Update time value
    ///
    /// - parameter time: Positive time interval describes current moment in video
    func seek(to time: TimeInterval)
}

class TimeIndicatorView: UIView {

    private let config: KinescopePlayerTimeindicatorConfiguration

    init(config: KinescopePlayerTimeindicatorConfiguration) {
        self.config = config
        super.init(frame: .zero)
        setupInitialState(with: config)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        .init(width: config.font.capHeight * 6, height: config.font.lineHeight)
    }

}

// MARK: - Private

private extension TimeIndicatorView {

    func setupInitialState(with config: KinescopePlayerTimeindicatorConfiguration) {
        // configure timeline

        backgroundColor = config.color
    }

}
