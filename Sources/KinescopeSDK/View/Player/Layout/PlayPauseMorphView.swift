import UIKit

/// Center play/pause button with path morph between glyphs (as in Android SDK).
/// Shows static replay glyph when video ended.
final class PlayPauseMorphView: UIView {

    private enum Constants {
        static let viewport = CGSize(width: 26, height: 24)
        static let pauseOffset: CGFloat = 1
        static let playOffset: CGFloat = 2.7
        static let morphDuration: CFTimeInterval = 0.09
        static let pressScale: CGFloat = 1.08
        static let pressDuration: TimeInterval = 0.09
        /// Glyph inset inside 72pt circle, scaled with button size.
        static let glyphInsetRatio: CGFloat = 22.0 / 72.0
        static let replayInsetRatio: CGFloat = 10.0 / 72.0
        static let timing = CAMediaTimingFunction(controlPoints: 0.4, 0, 0.2, 1)

        static let pauseLeft = "M9.333,7.2 C9.333,6.133 9.333,5.066 9.333,4 C9.333,3.705 9.286,3.422 9.197,3.157 C9.109,2.892 8.981,2.645 8.819,2.425 C8.657,2.204 8.462,2.009 8.242,1.848 C8.021,1.686 7.774,1.557 7.51,1.469 C7.245,1.381 6.961,1.333 6.667,1.333 C6.372,1.333 6.089,1.381 5.824,1.469 C5.559,1.557 5.312,1.686 5.092,1.848 C4.871,2.009 4.676,2.204 4.515,2.425 C4.353,2.645 4.224,2.892 4.136,3.157 C4.048,3.422 4,3.705 4,4 C4,5.066 4,6.133 4,7.2 C4,8.266 4,9.333 4,10.4 C4,11.466 4,12.533 4,13.6 C4,14.666 4,15.733 4,16.8 C4,17.866 4,18.933 4,20 C4,20.294 4.048,20.578 4.136,20.843 C4.224,21.107 4.353,21.354 4.515,21.575 C4.676,21.795 4.871,21.99 5.092,22.152 C5.312,22.314 5.559,22.442 5.824,22.53 C6.089,22.619 6.372,22.666 6.667,22.666 C6.961,22.666 7.245,22.619 7.51,22.53 C7.774,22.442 8.021,22.314 8.242,22.152 C8.462,21.99 8.657,21.795 8.819,21.575 C8.981,21.354 9.109,21.107 9.197,20.843 C9.286,20.578 9.333,20.294 9.333,20 C9.333,18.933 9.333,17.866 9.333,16.8 C9.333,15.733 9.333,14.666 9.333,13.6 C9.333,12.533 9.333,11.466 9.333,10.4 C9.333,9.333 9.333,8.266 9.333,7.2 Z"
        static let pauseRight = "M14.667,4 C14.667,2.527 15.861,1.333 17.333,1.333 C18.806,1.333 20,2.527 20,4 C20,9.333 20,14.666 20,20 C20,21.472 18.806,22.666 17.333,22.666 C15.861,22.666 14.667,21.472 14.667,20 C14.667,14.666 14.667,9.333 14.667,4 Z"
        static let playLeft = "M13.621,5.655 C12.989,5.287 12.357,4.919 11.726,4.551 C11.094,4.184 10.462,3.816 9.83,3.448 C9.198,3.08 8.566,2.712 7.935,2.344 C7.233,1.936 6.649,1.596 6.15,1.327 C5.65,1.058 5.236,0.86 4.874,0.737 C4.512,0.614 4.204,0.566 3.916,0.595 C3.665,0.621 3.421,0.682 3.192,0.774 C2.962,0.867 2.746,0.991 2.551,1.143 C2.356,1.295 2.181,1.474 2.032,1.678 C1.862,1.912 1.748,2.203 1.672,2.578 C1.597,2.952 1.559,3.41 1.54,3.977 C1.521,4.544 1.521,5.22 1.521,6.031 C1.521,7.383 1.521,8.734 1.521,10.085 C1.521,11.437 1.521,12.788 1.521,14.139 C1.521,15.491 1.521,16.842 1.521,18.193 C1.521,18.973 1.521,19.622 1.539,20.167 C1.557,20.712 1.594,21.153 1.667,21.515 C1.74,21.878 1.849,22.162 2.013,22.393 C2.156,22.595 2.325,22.773 2.514,22.926 C2.703,23.078 2.912,23.204 3.135,23.3 C3.358,23.395 3.595,23.461 3.84,23.493 C4.121,23.53 4.423,23.494 4.778,23.389 C5.132,23.284 5.539,23.11 6.029,22.872 C6.52,22.633 7.094,22.329 7.782,21.965 C8.431,21.622 9.08,21.279 9.729,20.936 C10.377,20.593 11.026,20.25 11.675,19.907 C12.324,19.563 12.972,19.22 13.621,18.877 C13.621,17.408 13.621,15.939 13.621,14.47 C13.621,13.001 13.621,11.532 13.621,10.062 C13.621,8.593 13.621,7.124 13.621,5.655 Z"
        static let playRight = "M12.421,4.956 C14.574,6.21 16.727,7.464 18.881,8.717 C21.048,9.98 22.132,10.611 22.48,11.421 C22.782,12.127 22.766,12.929 22.435,13.622 C22.055,14.417 20.946,15.004 18.728,16.176 C16.626,17.288 14.523,18.4 12.421,19.512 C12.421,14.66 12.421,9.808 12.421,4.956 Z"
        /// Android `kinescope_ic_controls_rewind`, shown when playback has finished.
        static let replay = "M25.5,36 C32.127,36 37.5,30.627 37.5,24 C37.5,17.373 32.127,12 25.5,12 C20.275,12 15.83,15.339 14.183,20 L16.572,20 C17.292,20 17.738,20.226 17.911,20.678 C18.097,21.131 17.991,21.663 17.591,22.276 L13.135,29.234 C12.802,29.745 12.422,30 11.996,30 C11.569,29.985 11.196,29.73 10.877,29.234 L6.4,22.254 C6.014,21.656 5.907,21.131 6.08,20.678 C6.267,20.226 6.713,20 7.419,20 L10.004,20 C11.78,13.099 18.045,8 25.5,8 C34.337,8 41.5,15.163 41.5,24 C41.5,32.837 34.337,40 25.5,40 C24.04,40 22.625,39.804 21.281,39.438 C20.193,39.141 19.724,37.908 20.191,36.881 C20.635,35.904 21.773,35.46 22.818,35.699 C23.681,35.896 24.578,36 25.5,36 Z"
        static let replayViewport = CGSize(width: 48, height: 48)
    }

    // MARK: - Properties

    private let glyphLayer = CALayer()
    private let leftLayer = CAShapeLayer()
    private let rightLayer = CAShapeLayer()
    private let replayLayer = CAShapeLayer()

    private(set) var isPlaying = false
    private(set) var isShowingReplay = false

    var glyphColor: UIColor = .white {
        didSet {
            leftLayer.fillColor = glyphColor.cgColor
            rightLayer.fillColor = glyphColor.cgColor
            replayLayer.fillColor = glyphColor.cgColor
        }
    }

    // MARK: - Lifecycle

    init(backgroundColor: UIColor) {
        super.init(frame: .zero)
        self.backgroundColor = backgroundColor
        setupInitialState()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2

        let inset = bounds.width * Constants.glyphInsetRatio
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        glyphLayer.frame = bounds.insetBy(dx: inset, dy: inset)
        // A zero-sized shape layer draws nothing, so the circle stayed and the glyph did not.
        leftLayer.frame = glyphLayer.bounds
        rightLayer.frame = glyphLayer.bounds
        applyPaths(playing: isPlaying)
        CATransaction.commit()

        let replayInset = bounds.width * Constants.replayInsetRatio
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        replayLayer.frame = bounds.insetBy(dx: replayInset, dy: replayInset)
        if isShowingReplay {
            applyReplayPath()
        }
        CATransaction.commit()
    }

    // MARK: - Methods

    func set(playing: Bool, animated: Bool) {
        // A pause at the end of the item must not replace the replay glyph with play.
        guard !isShowingReplay || playing else {
            return
        }
        let leavingReplay = isShowingReplay
        if leavingReplay {
            isShowingReplay = false
            replayLayer.isHidden = true
            glyphLayer.isHidden = false
        }
        guard leavingReplay || playing != isPlaying else {
            return
        }

        let fromLeft = leftLayer.presentation()?.path ?? leftLayer.path
        let fromRight = rightLayer.presentation()?.path ?? rightLayer.path
        isPlaying = playing
        applyPaths(playing: playing)

        guard animated, !leavingReplay, window != nil else {
            return
        }
        animatePath(of: leftLayer, from: fromLeft)
        animatePath(of: rightLayer, from: fromRight)
    }

    func showReplay() {
        isShowingReplay = true
        glyphLayer.isHidden = true
        replayLayer.isHidden = false
        applyReplayPath()
    }

    // MARK: - Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animatePress(scale: Constants.pressScale)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animatePress(scale: 1)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animatePress(scale: 1)
    }

    /// Light zoom feedback when tap was handled by parent gesture recognizer.
    func pulse() {
        UIView.animate(withDuration: Constants.pressDuration, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            self.transform = CGAffineTransform(scaleX: Constants.pressScale, y: Constants.pressScale)
        } completion: { _ in
            self.animatePress(scale: 1)
        }
    }

}

// MARK: - Private

private extension PlayPauseMorphView {

    func setupInitialState() {
        clipsToBounds = true
        isUserInteractionEnabled = false

        [leftLayer, rightLayer].forEach {
            $0.fillColor = glyphColor.cgColor
            glyphLayer.addSublayer($0)
        }
        layer.addSublayer(glyphLayer)

        replayLayer.fillColor = glyphColor.cgColor
        replayLayer.fillRule = .evenOdd
        replayLayer.isHidden = true
        layer.addSublayer(replayLayer)
    }

    func applyReplayPath() {
        let size = replayLayer.bounds.size
        guard size.width > 0 else {
            return
        }
        let scale = min(size.width / Constants.replayViewport.width,
                        size.height / Constants.replayViewport.height)
        let transform = CGAffineTransform(translationX: (size.width - Constants.replayViewport.width * scale) / 2,
                                           y: (size.height - Constants.replayViewport.height * scale) / 2)
            .scaledBy(x: scale, y: scale)
        replayLayer.path = SVGPath.make(Constants.replay, transform: transform)
    }

    func applyPaths(playing: Bool) {
        let size = glyphLayer.bounds.size
        guard size.width > 0 else {
            return
        }
        let scale = min(size.width / Constants.viewport.width, size.height / Constants.viewport.height)
        let offsetX = (size.width - Constants.viewport.width * scale) / 2
        let offsetY = (size.height - Constants.viewport.height * scale) / 2
        let nudge = playing ? Constants.pauseOffset : Constants.playOffset
        let transform = CGAffineTransform(translationX: offsetX, y: offsetY)
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: nudge, y: 0)

        leftLayer.path = SVGPath.make(playing ? Constants.pauseLeft : Constants.playLeft, transform: transform)
        rightLayer.path = SVGPath.make(playing ? Constants.pauseRight : Constants.playRight, transform: transform)
    }

    func animatePath(of shapeLayer: CAShapeLayer, from path: CGPath?) {
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = path
        animation.toValue = shapeLayer.path
        animation.duration = Constants.morphDuration
        animation.timingFunction = Constants.timing
        shapeLayer.add(animation, forKey: "morph")
    }

    func animatePress(scale: CGFloat) {
        UIView.animate(withDuration: Constants.pressDuration, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }

}
