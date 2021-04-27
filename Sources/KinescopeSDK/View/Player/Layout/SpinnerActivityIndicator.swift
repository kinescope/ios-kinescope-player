//
//  SpinnerActivityIndicator.swift
//  KinescopeSDK
//
//  Created by Никита Гагаринов on 27.04.2021.
//

import UIKit
import QuartzCore

public final class KinescopeSpinner: UIView, KinescopeActivityIndicating {

    // MARK: - Private Properties

    lazy private var animationLayer: CALayer = {
        return CALayer()
    }()

    // MARK: - Initialization

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure(frame: self.frame)
    }

    // MARK: - Public Methods

    public func showVideoProgress(isLoading: Bool) {
        if isLoading {
            isHidden = false
            resume(layer: animationLayer)
        } else {
            pause(layer: animationLayer)
            isHidden = true
        }
    }

}

// MARK: - Private Methods

private extension KinescopeSpinner {

    func configure(frame: CGRect) {
        let loadingImage = UIImage.image(named: "spinner")
        animationLayer.frame = frame
        animationLayer.contents = loadingImage.cgImage
        animationLayer.masksToBounds = true

        self.layer.addSublayer(animationLayer)
        addRotation(forLayer: animationLayer)
        pause(layer: animationLayer)
        self.isHidden = true
    }

    func addRotation(forLayer layer: CALayer) {
        let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")

        rotation.duration = 1.0
        rotation.isRemovedOnCompletion = false
        rotation.repeatCount = HUGE
        rotation.fillMode = CAMediaTimingFillMode.forwards
        rotation.fromValue = NSNumber(value: 0.0)
        rotation.toValue = NSNumber(value: Double.pi * 2.0)

        layer.add(rotation, forKey: "rotate")
    }

    func pause(layer: CALayer) {
        let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)

        layer.speed = 0.0
        layer.timeOffset = pausedTime
    }

    func resume(layer: CALayer) {
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
    }

}

