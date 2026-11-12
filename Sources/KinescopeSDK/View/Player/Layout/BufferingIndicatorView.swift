import UIKit

/// Rotating arc used as default loading indicator (Android `kinescope_ic_buffering`).
final class BufferingIndicatorView: UIView, KinescopeActivityIndicating {

    private enum Constants {
        static let size: CGFloat = 32
        static let rotationDuration: CFTimeInterval = 1
        static let animationKey = "rotation"
    }

    private let imageView = UIImageView(image: .image(named: "buffering"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        isHidden = true
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        addSubview(imageView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: Constants.size, height: Constants.size)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil, !isHidden {
            startRotation()
        }
    }

    func showVideoProgress(isLoading: Bool) {
        isHidden = !isLoading
        if isLoading {
            startRotation()
        } else {
            imageView.layer.removeAnimation(forKey: Constants.animationKey)
        }
    }

    private func startRotation() {
        guard imageView.layer.animation(forKey: Constants.animationKey) == nil else {
            return
        }
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = CGFloat.pi * 2
        animation.duration = Constants.rotationDuration
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        imageView.layer.add(animation, forKey: Constants.animationKey)
    }

}
