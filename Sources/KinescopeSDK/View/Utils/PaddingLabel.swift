import UIKit

/// Label with content insets.
final class PaddingLabel: UILabel {

    private let insets: UIEdgeInsets

    init(insets: UIEdgeInsets) {
        self.insets = insets
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right,
                      height: size.height + insets.top + insets.bottom)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let fitting = super.sizeThatFits(CGSize(width: size.width - insets.left - insets.right,
                                                height: size.height))
        return CGSize(width: fitting.width + insets.left + insets.right,
                      height: fitting.height + insets.top + insets.bottom)
    }

}
