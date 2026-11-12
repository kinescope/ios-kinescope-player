import UIKit

/// Edge hemisphere with running chevrons and accumulated seconds shown on double tap seek.
final class SeekFeedbackView: UIView {

    enum Edge {
        case leading
        case trailing
    }

    private enum Constants {
        static let inlineDiameter: CGFloat = 340
        /// Landscape fullscreen circle diameter relative to the player height.
        static let fullscreenHeightScale: CGFloat = 1.45
        /// Portrait fullscreen oval width relative to the player width.
        static let fullscreenPortraitWidthScale: CGFloat = 1.2
        /// Portrait oval is stretched past the player so the clipped edge stays tall.
        static let portraitOvalHeightStretch: CGFloat = 1.45
        static let portraitOvalMinAspect: CGFloat = 2.6
        static let contentOffsetInRadius: CGFloat = 0.42
        static let iconSize = CGSize(width: 31, height: 12)
        static let labelGap: CGFloat = 4
        static let visibleDuration: TimeInterval = 0.5
        static let showDuration: TimeInterval = 0.18
        static let hideDuration: TimeInterval = 0.15
        static let collapsedScale: CGFloat = 0.88
        static let hemisphereColor = UIColor.black.withAlphaComponent(0.4)
    }

    // MARK: - Properties

    private let edge: Edge
    private let hemisphere = UIView()
    private let ovalMask = CAShapeLayer()
    private let chevrons: SeekChevronsView
    private let label = UILabel()
    private var hideWorkItem: DispatchWorkItem?
    private var ovalSize = CGSize(width: Constants.inlineDiameter, height: Constants.inlineDiameter)

    // MARK: - Lifecycle

    init(edge: Edge) {
        self.edge = edge
        self.chevrons = SeekChevronsView(forward: edge == .trailing)
        super.init(frame: .zero)
        setupInitialState()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        hemisphere.bounds = CGRect(origin: .zero, size: ovalSize)
        hemisphere.center = CGPoint(x: edge == .leading ? 0 : bounds.width, y: bounds.midY)
        ovalMask.frame = hemisphere.bounds
        ovalMask.path = UIBezierPath(ovalIn: hemisphere.bounds).cgPath
        hemisphere.layer.mask = ovalMask

        let half = bounds.width

        let contentOffset = half * Constants.contentOffsetInRadius
        let labelSize = label.intrinsicContentSize
        let contentHeight = Constants.iconSize.height + Constants.labelGap + labelSize.height
        let contentWidth = max(Constants.iconSize.width, labelSize.width)
        let contentCenterX = edge == .leading
            ? contentOffset + contentWidth / 2
            : bounds.width - contentOffset - contentWidth / 2
        let top = bounds.midY - contentHeight / 2

        chevrons.frame = CGRect(x: contentCenterX - Constants.iconSize.width / 2, y: top,
                                width: Constants.iconSize.width, height: Constants.iconSize.height)
        label.frame = CGRect(x: contentCenterX - labelSize.width / 2,
                             y: chevrons.frame.maxY + Constants.labelGap,
                             width: labelSize.width, height: labelSize.height)
    }

    // MARK: - Methods

    /// Visible half of the oval. Fullscreen uses the Android scales; inline stays a 340pt circle.
    func preferredWidth(in container: CGSize, screen: CGSize?, portraitVideo: Bool) -> CGFloat {
        let next = Self.ovalSize(in: container, screen: screen, portraitVideo: portraitVideo)
        if next != ovalSize {
            ovalSize = next
            setNeedsLayout()
        }
        return min(ovalSize.width / 2, container.width)
    }

    private static func ovalSize(in container: CGSize, screen: CGSize?, portraitVideo: Bool) -> CGSize {
        let fullscreen = isFullscreen(container, screen: screen)
        if fullscreen, portraitVideo, container.width > 1, container.height > 1 {
            let width = container.width * Constants.fullscreenPortraitWidthScale
            let height = max(container.height * Constants.portraitOvalHeightStretch,
                             width * Constants.portraitOvalMinAspect)
            return CGSize(width: width, height: height)
        }
        if fullscreen, container.height > 1 {
            let diameter = container.height * Constants.fullscreenHeightScale
            return CGSize(width: diameter, height: diameter)
        }
        let diameter = min(Constants.inlineDiameter, container.width * 0.9)
        return CGSize(width: diameter, height: diameter)
    }

    private static func isFullscreen(_ container: CGSize, screen: CGSize?) -> Bool {
        guard let screen, screen.width > 1, screen.height > 1 else {
            return false
        }
        return container.width >= screen.width - 12 && container.height >= screen.height - 12
    }

    func show(totalSeconds: Int) {
        label.text = L10n.Player.seconds(totalSeconds)
        setNeedsLayout()

        hideWorkItem?.cancel()
        let alreadyVisible = !isHidden && alpha > 0.5
        layer.removeAllAnimations()

        if !alreadyVisible {
            isHidden = false
            alpha = 0
            transform = collapsedTransform()
            UIView.animate(withDuration: Constants.showDuration, delay: 0, options: [.allowUserInteraction, .curveEaseOut]) {
                self.alpha = 1
                self.transform = .identity
            }
        } else {
            alpha = 1
            transform = .identity
        }
        chevrons.startRipple()

        let workItem = DispatchWorkItem { [weak self] in
            self?.hide()
        }
        hideWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.visibleDuration, execute: workItem)
    }

    func hide() {
        hideWorkItem?.cancel()
        UIView.animate(withDuration: Constants.hideDuration, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.alpha = 0
        } completion: { finished in
            guard finished else {
                return
            }
            self.isHidden = true
            self.chevrons.stopRipple()
        }
    }

}

// MARK: - Private

private extension SeekFeedbackView {

    func setupInitialState() {
        isUserInteractionEnabled = false
        clipsToBounds = true
        isHidden = true

        hemisphere.backgroundColor = Constants.hemisphereColor
        addSubview(hemisphere)
        addSubview(chevrons)

        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        addSubview(label)
    }

    /// Scale from the player edge like Android pivot.
    func collapsedTransform() -> CGAffineTransform {
        let scale = Constants.collapsedScale
        let pivotX = edge == .leading ? -bounds.width / 2 : bounds.width / 2
        return CGAffineTransform(translationX: pivotX, y: 0)
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: -pivotX, y: 0)
    }

}

// MARK: - Chevrons

/// Three chevrons with running opacity wave.
final class SeekChevronsView: UIView {

    private enum Constants {
        static let viewport = CGSize(width: 31, height: 12)
        static let minAlpha: Float = 0.25
        static let cycle: CFTimeInterval = 1.1

        static let forward = [
            "M0.5,10.132C0.5,10.93 1.39,11.407 2.055,10.964L8.252,6.832C8.846,6.436 8.846,5.564 8.252,5.168L2.055,1.036C1.39,0.593 0.5,1.07 0.5,1.869V10.132Z",
            "M19.252,5.168C19.846,5.564 19.846,6.436 19.252,6.832L13.055,10.964C12.39,11.407 11.5,10.93 11.5,10.132L11.5,1.869C11.5,1.07 12.39,0.593 13.055,1.036L19.252,5.168Z",
            "M30.252,5.168C30.846,5.564 30.846,6.436 30.252,6.832L24.055,10.964C23.39,11.407 22.5,10.93 22.5,10.132V1.869C22.5,1.07 23.39,0.593 24.055,1.036L30.252,5.168Z"
        ]
        static let backward = [
            "M30.5,10.132C30.5,10.93 29.61,11.407 28.945,10.964L22.748,6.832C22.154,6.436 22.154,5.564 22.748,5.168L28.945,1.036C29.61,0.593 30.5,1.07 30.5,1.869V10.132Z",
            "M11.748,5.168C11.154,5.564 11.154,6.436 11.748,6.832L17.945,10.964C18.61,11.407 19.5,10.93 19.5,10.132V1.869C19.5,1.07 18.61,0.593 17.945,1.036L11.748,5.168Z",
            "M0.748,5.168C0.154,5.564 0.154,6.436 0.748,6.832L6.945,10.964C7.61,11.407 8.5,10.93 8.5,10.132V1.869C8.5,1.07 7.61,0.593 6.945,1.036L0.748,5.168Z"
        ]
    }

    private let shapeLayers: [CAShapeLayer]
    private let paths: [String]

    init(forward: Bool) {
        paths = forward ? Constants.forward : Constants.backward
        shapeLayers = paths.map { _ in
            let layer = CAShapeLayer()
            layer.fillColor = UIColor.white.cgColor
            return layer
        }
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        shapeLayers.forEach(layer.addSublayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let scale = min(bounds.width / Constants.viewport.width, bounds.height / Constants.viewport.height)
        let transform = CGAffineTransform(translationX: (bounds.width - Constants.viewport.width * scale) / 2,
                                          y: (bounds.height - Constants.viewport.height * scale) / 2)
            .scaledBy(x: scale, y: scale)
        zip(shapeLayers, paths).forEach { layer, data in
            layer.frame = bounds
            layer.path = SVGPath.make(data, transform: transform)
        }
    }

    func startRipple() {
        guard shapeLayers.first?.animation(forKey: "ripple") == nil else {
            return
        }
        let now = CACurrentMediaTime()
        // Chevron order is always the movement direction: index 0 lights up first.
        for (index, layer) in shapeLayers.enumerated() {
            let animation = CAKeyframeAnimation(keyPath: "opacity")
            animation.values = [Constants.minAlpha, 1, Constants.minAlpha, Constants.minAlpha]
            animation.keyTimes = [0, 0.27, 0.6, 1]
            animation.duration = Constants.cycle
            animation.repeatCount = .infinity
            animation.beginTime = now + Constants.cycle / 3 * Double(index) - Constants.cycle
            layer.opacity = Constants.minAlpha
            layer.add(animation, forKey: "ripple")
        }
    }

    func stopRipple() {
        shapeLayers.forEach {
            $0.removeAnimation(forKey: "ripple")
            $0.opacity = 1
        }
    }

}
