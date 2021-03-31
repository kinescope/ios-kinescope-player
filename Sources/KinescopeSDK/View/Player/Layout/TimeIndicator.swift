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

    init(config: KinescopePlayerTimeindicatorConfiguration) {
        super.init(frame: .zero)
        setupInitialState(with: config)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Private

private extension TimeIndicatorView {

    func setupInitialState(with config: KinescopePlayerTimeindicatorConfiguration) {
        // configure timeline

        backgroundColor = config.color
    }

}
