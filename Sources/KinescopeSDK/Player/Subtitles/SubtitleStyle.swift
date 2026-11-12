import UIKit

/// Caption look, same options as on Android.
struct SubtitleStyle: Equatable {
    var fontColor: UIColor = .white
    var fontSizePercent: Int = 100
    var backgroundColor: UIColor = .black
    var backgroundOpacityPercent: Int = 75

    static let fontSizes = [50, 75, 100, 125, 150, 200, 300]
    static let opacities = [0, 25, 50, 75, 100]

    static var colors: [(name: String, color: UIColor)] {
        [
            (L10n.Player.colorWhite, .white),
            (L10n.Player.colorGreen, UIColor(red: 0, green: 1, blue: 0, alpha: 1)),
            (L10n.Player.colorCyan, UIColor(red: 0, green: 1, blue: 1, alpha: 1)),
            (L10n.Player.colorBlue, UIColor(red: 0, green: 0, blue: 1, alpha: 1)),
            (L10n.Player.colorMagenta, UIColor(red: 1, green: 0, blue: 1, alpha: 1)),
            (L10n.Player.colorRed, UIColor(red: 1, green: 0, blue: 0, alpha: 1)),
            (L10n.Player.colorBlack, .black)
        ]
    }

    func colorName(for color: UIColor) -> String {
        Self.colors.first { $0.color.matchesRGB(color) }?.name ?? L10n.Player.colorWhite
    }
}

extension UIColor {

    func matchesRGB(_ other: UIColor) -> Bool {
        var left = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
        var right = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
        guard getRed(&left.0, green: &left.1, blue: &left.2, alpha: &left.3),
              other.getRed(&right.0, green: &right.1, blue: &right.2, alpha: &right.3) else {
            return false
        }
        return abs(left.0 - right.0) < 0.02
            && abs(left.1 - right.1) < 0.02
            && abs(left.2 - right.2) < 0.02
    }

}
