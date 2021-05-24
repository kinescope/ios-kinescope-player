import UIKit

extension String {

    /// Adds to string HD/4K icons if needed
    /// - Parameter attributes: attributes for NSAttributedString
    /// - Returns: attributed string with icon insered
    func attributedStringWithAssetIconIfNeeded(
        attributes: [NSAttributedString.Key: Any]
    ) -> NSAttributedString {

        let attrubutedString = NSMutableAttributedString(string: self, attributes: attributes)

        let attachment = NSTextAttachment()
        if hasPrefix("720") || hasPrefix("1080") || hasPrefix("1440") {
            attachment.image = .image(named: "HD")
        } else if hasPrefix("2160") {
            attachment.image = .image(named: "uhd")
        } else {
            return attrubutedString
        }

        let fontSize = (attributes[.font] as? UIFont)?.pointSize ?? .zero
        let y = fontSize / 2.0
        attachment.bounds = .init(x: .zero, y: -y, width: 24.0, height: 24.0)

        attrubutedString.append(.init(attachment: attachment))

        return attrubutedString
    }
}
