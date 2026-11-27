//
//  WatermarkView.swift
//  KinescopeSDK
//

import AVFoundation
import UIKit

/// Server watermark with defaults applied and the CSS values converted.
struct WatermarkStyle: Equatable {

    enum Mode {
        case random
        case stripes
    }

    static let defaultScale: CGFloat = 0.25
    static let defaultColor = UIColor(white: 1, alpha: 0.4)

    let text: String
    let mode: Mode
    let scale: CGFloat
    /// Seconds on screen, then `hidden` seconds off. Both `0`: always shown.
    let visible: TimeInterval
    let hidden: TimeInterval
    let color: UIColor

    var blinks: Bool {
        visible > 0 && hidden > 0
    }

    /// `nil` when there is no watermark or its text is blank.
    init?(_ source: KinescopeWatermark?) {
        guard let text = source?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            return nil
        }
        self.text = text
        mode = source?.mode?.lowercased() == "stripes" ? .stripes : .random
        if let scale = source?.scale, scale.isFinite, scale > 0 {
            self.scale = CGFloat(min(scale, 1))
        } else {
            scale = Self.defaultScale
        }
        visible = max(source?.displayTimeout?.visible ?? 0, 0) / 1000
        hidden = max(source?.displayTimeout?.hidden ?? 0, 0) / 1000
        color = Self.color(css: source?.color) ?? Self.defaultColor
    }

    /// CSS `#RGB`, `#RGBA`, `#RRGGBB`, `#RRGGBBAA`. `nil` if the value is not one of them.
    static func color(css value: String?) -> UIColor? {
        guard var hex = value?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return nil
        }
        if hex.hasPrefix("#") {
            hex.removeFirst()
        }
        guard hex.allSatisfy({ $0.isHexDigit }) else {
            return nil
        }
        switch hex.count {
        case 3, 4:
            hex = hex.map { "\($0)\($0)" }.joined()
        case 6, 8:
            break
        default:
            return nil
        }
        guard let number = UInt64(hex, radix: 16) else {
            return nil
        }
        let hasAlpha = hex.count == 8
        let rgb = hasAlpha ? number >> 8 : number
        let alpha = hasAlpha ? CGFloat(number & 0xFF) / 255 : 1
        return UIColor(red: CGFloat((rgb >> 16) & 0xFF) / 255,
                       green: CGFloat((rgb >> 8) & 0xFF) / 255,
                       blue: CGFloat(rgb & 0xFF) / 255,
                       alpha: alpha)
    }
}

/// Draws the server watermark over the picture, like the web player: `random` jumps to a random
/// place, `stripes` repeats in diagonal rows, `display_timeout` makes it blink. Sits on the video
/// surface, so it follows pinch-to-zoom and fullscreen. Takes no touches.
final class WatermarkView: UIView {

    private enum Constants {
        /// Random mode without blinking: how often the text jumps.
        static let moveInterval: TimeInterval = 6
        static let referenceFontSize: CGFloat = 100
        static let minFontSize: CGFloat = 10
        static let maxTextHeightFraction: CGFloat = 0.15
        static let edgeMargin: CGFloat = 8
        static let stripeAngle: CGFloat = -30 * .pi / 180
        static let stripeRowSpacing: CGFloat = 4
        static let maxStripeSteps = 50
    }

    /// The picture inside the view. Until the video size is known the whole view is used.
    weak var playerLayer: AVPlayerLayer?

    var style: WatermarkStyle? {
        didSet {
            guard style != oldValue else {
                return
            }
            textShown = true
            isHidden = style == nil
            moveRandomly()
            schedule()
            setNeedsDisplay()
        }
    }

    var text: String? {
        style?.text
    }

    private var textShown = true
    private var position = CGPoint(x: 0.5, y: 0.5)
    private var timer: Timer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        isOpaque = false
        backgroundColor = .clear
        contentMode = .redraw
        isAccessibilityElement = false
        isHidden = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        timer?.invalidate()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        schedule()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let style, textShown, let context = UIGraphicsGetCurrentContext() else {
            return
        }
        let area = pictureRect
        guard area.width > 1, area.height > 1 else {
            return
        }
        context.saveGState()
        context.clip(to: area)
        let attributes = textAttributes(for: style, in: area)
        let size = (style.text as NSString).size(withAttributes: attributes)
        switch style.mode {
        case .random:
            drawRandom(style.text, size: size, attributes: attributes, in: area)
        case .stripes:
            drawStripes(style.text, size: size, attributes: attributes, in: area, context: context)
        }
        context.restoreGState()
    }
}

// MARK: - Private

private extension WatermarkView {

    var pictureRect: CGRect {
        if let playerLayer {
            let video = playerLayer.videoRect
            if video.width > 1, video.height > 1 {
                return layer.convert(video, from: playerLayer)
            }
        }
        return bounds
    }

    func schedule() {
        timer?.invalidate()
        timer = nil
        guard let style, window != nil else {
            return
        }
        let delay: TimeInterval
        if style.blinks {
            delay = textShown ? style.visible : style.hidden
        } else if style.mode == .random {
            delay = Constants.moveInterval
        } else {
            return
        }
        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.tick()
        }
    }

    func tick() {
        guard let style else {
            return
        }
        if style.blinks {
            textShown.toggle()
            if textShown {
                moveRandomly()
            }
        } else {
            moveRandomly()
        }
        setNeedsDisplay()
        schedule()
    }

    func moveRandomly() {
        position = CGPoint(x: CGFloat.random(in: 0...1), y: CGFloat.random(in: 0...1))
    }

    func textAttributes(for style: WatermarkStyle, in area: CGRect) -> [NSAttributedString.Key: Any] {
        let reference = UIFont.boldSystemFont(ofSize: Constants.referenceFontSize)
        let referenceWidth = max((style.text as NSString).size(withAttributes: [.font: reference]).width, 1)
        let target = area.width * style.scale / referenceWidth * Constants.referenceFontSize
        let maxSize = max(area.height * Constants.maxTextHeightFraction, Constants.minFontSize)
        let fontSize = min(max(target, Constants.minFontSize), maxSize)

        let shadow = NSShadow()
        shadow.shadowBlurRadius = 1.5
        shadow.shadowOffset = .zero
        shadow.shadowColor = UIColor.black.withAlphaComponent(0.35)
        return [
            .font: UIFont.boldSystemFont(ofSize: fontSize),
            .foregroundColor: style.color,
            .shadow: shadow
        ]
    }

    func drawRandom(_ text: String, size: CGSize, attributes: [NSAttributedString.Key: Any], in area: CGRect) {
        let margin = Constants.edgeMargin
        let freeX = max(area.width - size.width - 2 * margin, 0)
        let freeY = max(area.height - size.height - 2 * margin, 0)
        let origin = CGPoint(x: area.minX + margin + freeX * position.x,
                             y: area.minY + margin + freeY * position.y)
        (text as NSString).draw(at: origin, withAttributes: attributes)
    }

    func drawStripes(_ text: String,
                     size: CGSize,
                     attributes: [NSAttributedString.Key: Any],
                     in area: CGRect,
                     context: CGContext) {
        guard size.width > 0, size.height > 0 else {
            return
        }
        let stepX = size.width + size.height * 2
        let stepY = size.height * Constants.stripeRowSpacing
        let center = CGPoint(x: area.midX, y: area.midY)
        let radius = hypot(area.width, area.height) / 2
        // Bounded: a degenerate font must not turn into millions of draw calls.
        let rows = min(Int(ceil(radius / stepY)), Constants.maxStripeSteps)
        let columns = min(Int(ceil(radius / stepX)) + 1, Constants.maxStripeSteps)
        context.translateBy(x: center.x, y: center.y)
        context.rotate(by: Constants.stripeAngle)
        for row in -rows...rows {
            let shift = row.isMultiple(of: 2) ? 0 : stepX / 2
            let y = CGFloat(row) * stepY - size.height / 2
            for column in -columns...columns {
                let x = CGFloat(column) * stepX + shift - size.width / 2
                (text as NSString).draw(at: CGPoint(x: x, y: y), withAttributes: attributes)
            }
        }
    }
}
