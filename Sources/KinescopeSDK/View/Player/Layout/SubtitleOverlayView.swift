import UIKit

/// Captions drawn by the player from an external WebVTT or SubRip file.
final class SubtitleOverlayView: UIView {

    var onTap: (() -> Void)?

    private let label = PaddingLabel(insets: UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(captionTapped))
        addGestureRecognizer(tap)
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        label.layer.cornerRadius = 2
        label.layer.masksToBounds = true
        label.isHidden = true
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -64),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -12),
            label.widthAnchor.constraint(lessThanOrEqualToConstant: 280)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let labelPoint = convert(point, to: label)
        guard !label.isHidden, label.bounds.contains(labelPoint) else {
            return nil
        }
        return self
    }

    @objc
    func captionTapped() {
        onTap?()
    }

    func set(text: String?) {
        let value = text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        label.text = value
        label.isHidden = value.isEmpty
    }

    func apply(_ style: SubtitleStyle) {
        label.textColor = style.fontColor
        label.font = .systemFont(ofSize: 16 * CGFloat(style.fontSizePercent) / 100)
        let alpha = CGFloat(style.backgroundOpacityPercent) / 100
        label.backgroundColor = style.backgroundColor.withAlphaComponent(alpha)
    }

}
