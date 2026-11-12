import UIKit

enum ForegroundWindow {

    static var window: UIWindow? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let scene = scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
        return scene?.keyWindow ?? scene?.windows.first
    }

    static var rootViewController: UIViewController? {
        window?.rootViewController
    }

    /// Top-most presented controller of foreground window
    static var topViewController: UIViewController? {
        var top = rootViewController
        while let presented = top?.presentedViewController, !presented.isBeingDismissed {
            top = presented
        }
        return top
    }
}
