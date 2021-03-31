//
//  TimelineView.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 31.03.2021.
//

import UIKit

protocol TimelineInput {

    /// Update timeline position manualy
    ///
    /// - parameter position: Value from `0` (start) to `1` (end)
    func seek(to position: CGFloat)
}

protocol TimelineOutput: class {

    /// Callback of user initiated timeline changes like circle dragging or tap released
    ///
    /// - parameter position: Value from `0` (start) to `1` (end)
    func onTimelinePositionChanged(to position: CGFloat)

}

class TimelineView: UIControl {

    private let config: KinescopePlayerTimelineConfiguration

    init(config: KinescopePlayerTimelineConfiguration) {
        self.config = config
        super.init(frame: .zero)
        setupInitialState(with: config)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        .init(width: config.circleRadius * 10, height: config.circleRadius * 2)
    }

}

// MARK: - Private

private extension TimelineView {

    func setupInitialState(with config: KinescopePlayerTimelineConfiguration) {
        // configure timeline

        backgroundColor = config.activeColor
    }

}
