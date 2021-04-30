//
//  SpinnerActivityIndicator.swift
//  KinescopeSDK
//
//  Created by Никита Гагаринов on 27.04.2021.
//

import UIKit
import QuartzCore

public final class KinescopeSpinner: UIView, KinescopeActivityIndicating {

    // MARK: - Public Properties

    public var ringWidth: CGFloat = 5
    public var color = UIColor(red: 0.67, green: 0.67, blue: 0.67, alpha: 1.0)

    // MARK: - Private Properties

    private var progressLayer = CAShapeLayer()
    private var backgroundMask = CAShapeLayer()
    private var gradientLayer = CAGradientLayer()
    private var isActive = false

    // MARK: - Lifecycle

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        createAnimation()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayers()
        createAnimation()
    }

    public override func draw(_ rect: CGRect) {
        let circlePath = UIBezierPath(ovalIn: rect.insetBy(dx: ringWidth / 2, dy: ringWidth / 2))
        backgroundMask.path = circlePath.cgPath

        progressLayer.path = circlePath.cgPath
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd = 0.75
        progressLayer.strokeColor = UIColor.black.cgColor

        gradientLayer.frame = rect
        gradientLayer.colors = [color.cgColor, color.cgColor]
    }

    // MARK: - Public Methods

    public func showLoading(_ isLoading: Bool) {
        if isLoading {
            guard !isActive else {
                return
            }
            isActive = true
            isHidden = false
            guard progressLayer.animation(forKey: "line") != nil else {
                createAnimation()
                return
            }
            resume(layer: progressLayer)
            resume(layer: gradientLayer)
        } else {
            guard isActive else {
                return
            }
            isActive = false
            pause(layer: progressLayer)
            pause(layer: gradientLayer)
            isHidden = true
        }
    }

}

// MARK: - Private Methods

private extension KinescopeSpinner {

    func setupLayers() {
        backgroundMask.lineWidth = ringWidth
        backgroundMask.fillColor = nil
        backgroundMask.strokeColor = UIColor.black.cgColor
        layer.mask = backgroundMask

        progressLayer.lineWidth = ringWidth
        progressLayer.fillColor = nil

        layer.addSublayer(gradientLayer)

        gradientLayer.mask = progressLayer
        gradientLayer.locations = [0.35, 0.5, 0.65]
    }

    func createAnimation() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")

        rotationAnimation.fromValue = CGFloat(Double.pi / 2)
        rotationAnimation.toValue = CGFloat(2.5 * Double.pi)
        rotationAnimation.repeatCount = Float.infinity
        rotationAnimation.duration = 1.0

        gradientLayer.add(rotationAnimation, forKey: "rotationAnimation")
        resume(layer: gradientLayer)

        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0.2
        animation.toValue = 0.8
        animation.duration = 1.5
        animation.autoreverses = true
        animation.repeatCount = .infinity
        progressLayer.add(animation, forKey: "line")
        resume(layer: progressLayer)
    }

    func pause(layer: CALayer) {
        let pausedTime: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.timeOffset = pausedTime
        layer.speed = 0.0
    }

    func resume(layer: CALayer) {
        let pausedTime: CFTimeInterval = layer.timeOffset
        let timeSincePause: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
        layer.timeOffset = 0.0
        layer.speed = 1.0
    }

}


