import UIKit
import CoreText

/// Roboto faces used by the Android player settings.
enum KinescopeFont {

    static func regular(_ size: CGFloat) -> UIFont {
        face("Roboto-Regular", size: size, weight: .regular)
    }

    static func bold(_ size: CGFloat) -> UIFont {
        face("Roboto-Bold", size: size, weight: .bold)
    }

    private static func face(_ name: String, size: CGFloat, weight: UIFont.Weight) -> UIFont {
        register()
        return UIFont(name: name, size: size) ?? .systemFont(ofSize: size, weight: weight)
    }

    private static var didRegister = false

    private static func register() {
        guard !didRegister else { return }
        didRegister = true
        var bundle: Bundle
        #if SWIFT_PACKAGE
        bundle = .module
        #else
        bundle = Bundle(for: Manager.self)
        #endif
        if let path = bundle.resourcePath, let nested = Bundle(path: path + "/KinescopeSDK.bundle") {
            bundle = nested
        }
        let urls = (bundle.urls(forResourcesWithExtension: "ttf", subdirectory: nil) ?? [])
            + (bundle.urls(forResourcesWithExtension: "ttf", subdirectory: "Fonts") ?? [])
        for url in urls {
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
