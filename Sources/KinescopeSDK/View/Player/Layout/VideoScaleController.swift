import UIKit

/// Pinch to zoom (1x–5x) and pan of video layer with scale badge.
final class VideoScaleController: NSObject {

    private enum Constants {
        static let minScale: CGFloat = 1
        static let maxScale: CGFloat = 5
        static let badgeThreshold: CGFloat = 1.005
        static let resetDuration: TimeInterval = 0.25
        static let badgeSize: CGFloat = 40
        static let badgeTopMargin: CGFloat = 16
    }

    // MARK: - Properties

    private weak var container: UIView?
    private weak var target: UIView?
    private let badge = UIButton(type: .custom)
    private lazy var pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
    private lazy var pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))

    private(set) var scale: CGFloat = 1
    private var translation: CGPoint = .zero
    private var panOrigin: CGPoint = .zero

    /// Views which should keep receiving touches (controls, menus).
    var isTouchExcluded: (UITouch) -> Bool = { _ in false }

    // MARK: - Init

    init(container: UIView, target: UIView) {
        self.container = container
        self.target = target
        super.init()
        pinch.delegate = self
        pan.delegate = self
        container.addGestureRecognizer(pinch)
        container.addGestureRecognizer(pan)
        configureBadge(in: container)
    }

    // MARK: - Methods

    func reset(animated: Bool) {
        scale = Constants.minScale
        translation = .zero
        let apply: () -> Void = { [weak self] in
            self?.target?.transform = .identity
        }
        if animated {
            UIView.animate(withDuration: Constants.resetDuration, animations: apply)
        } else {
            apply()
        }
        updateBadge()
    }

    /// Settings step. `0.97` and `1.03` match the Android −3% / +3% rows.
    func multiply(by factor: CGFloat) {
        scale = min(Constants.maxScale, max(Constants.minScale, scale * factor))
        if scale <= Constants.badgeThreshold {
            translation = .zero
        }
        clampTranslation()
        applyTransform()
    }

    var percentText: String {
        "\(Int((scale * 100).rounded()))%"
    }

    func invalidate() {
        container?.removeGestureRecognizer(pinch)
        container?.removeGestureRecognizer(pan)
        badge.removeFromSuperview()
    }

}

// MARK: - UIGestureRecognizerDelegate

extension VideoScaleController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        !isTouchExcluded(touch)
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === pan {
            return scale > Constants.badgeThreshold
        }
        return true
    }

}

// MARK: - Private

private extension VideoScaleController {

    func configureBadge(in container: UIView) {
        badge.backgroundColor = UIColor.black.withAlphaComponent(0.64)
        badge.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        badge.setTitleColor(.white, for: .normal)
        badge.layer.cornerRadius = Constants.badgeSize / 2
        badge.isHidden = true
        badge.accessibilityLabel = L10n.Player.resetScale
        badge.addTarget(self, action: #selector(badgeTapped), for: .touchUpInside)

        container.addSubview(badge)
        badge.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            badge.widthAnchor.constraint(equalToConstant: Constants.badgeSize),
            badge.heightAnchor.constraint(equalToConstant: Constants.badgeSize),
            badge.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            badge.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor,
                                       constant: Constants.badgeTopMargin)
        ])
    }

    @objc
    func badgeTapped() {
        reset(animated: true)
    }

    @objc
    func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
        guard recognizer.state == .changed || recognizer.state == .began else {
            return
        }
        scale = min(Constants.maxScale, max(Constants.minScale, scale * recognizer.scale))
        recognizer.scale = 1
        if scale <= Constants.badgeThreshold {
            translation = .zero
        }
        clampTranslation()
        applyTransform()
    }

    @objc
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        guard scale > Constants.badgeThreshold else {
            return
        }
        guard pinch.state != .began, pinch.state != .changed else {
            return
        }
        switch recognizer.state {
        case .began:
            panOrigin = translation
        case .changed:
            let delta = recognizer.translation(in: container)
            translation = CGPoint(x: panOrigin.x + delta.x, y: panOrigin.y + delta.y)
            clampTranslation()
            applyTransform()
        default:
            break
        }
    }

    func clampTranslation() {
        guard let target, scale > Constants.minScale else {
            translation = .zero
            return
        }
        let maxX = target.bounds.width * (scale - 1) / 2
        let maxY = target.bounds.height * (scale - 1) / 2
        translation.x = min(max(translation.x, -maxX), maxX)
        translation.y = min(max(translation.y, -maxY), maxY)
    }

    func applyTransform() {
        // Scale around the centre, then move in the parent's points. The canvas clips the result.
        target?.transform = CGAffineTransform(translationX: translation.x, y: translation.y)
            .scaledBy(x: scale, y: scale)
        updateBadge()
    }

    func updateBadge() {
        guard scale > Constants.badgeThreshold else {
            badge.isHidden = true
            return
        }
        badge.isHidden = false
        badge.setTitle(Self.format(scale), for: .normal)
    }

    static func format(_ value: CGFloat) -> String {
        let rounded = (value * 10).rounded() / 10
        if abs(rounded - rounded.rounded()) < 0.05 {
            return "\(Int(rounded.rounded()))x"
        }
        return String(format: "%.1fx", locale: Locale(identifier: "en_US_POSIX"), Double(rounded))
    }

}
