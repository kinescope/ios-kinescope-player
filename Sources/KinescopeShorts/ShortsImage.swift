import UIKit

/// Images from the KinescopeShorts resource bundle.
enum ShortsImage {
    static func named(_ name: String) -> UIImage {
        let traitCollection = UITraitCollection(displayScale: UIScreen.main.scale)
        // swiftlint:disable:next image_name_initialization
        return UIImage(named: name, in: .module, compatibleWith: traitCollection) ?? UIImage()
    }
}
