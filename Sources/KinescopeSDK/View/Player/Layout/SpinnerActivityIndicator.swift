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

    public func showVideoProgress(isLoading: Bool) {
        if isLoading {
            isHidden = false
            resume(layer: gradientLayer)
            resume(layer: progressLayer)
        } else {
            pause(layer: gradientLayer)
            pause(layer: progressLayer)
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

        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 2.5
        animation.autoreverses = true
        animation.repeatCount = .infinity
        progressLayer.add(animation, forKey: "line")
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


