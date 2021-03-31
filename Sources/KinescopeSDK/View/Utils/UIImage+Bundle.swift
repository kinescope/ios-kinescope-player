import UIKit

extension UIImage {
    static func image(named: String) -> UIImage {
        let traitCollection = UITraitCollection(displayScale: UIScreen.main.scale)
        var bundle: Bundle
        #if SWIFT_PACKAGE
        bundle = Bundle.module
        #else
        bundle = Bundle(for: Manager.self)
        #endif
        if let resource = bundle.resourcePath, let resourceBundle = Bundle(path: resource + "/KinescopeSDK.bundle") {
            bundle = resourceBundle
        }

        return UIImage(named: named, in: bundle, compatibleWith: traitCollection) ?? UIImage()
    }
}
