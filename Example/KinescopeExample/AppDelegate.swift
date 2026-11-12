import UIKit
import KinescopeSDK
import AVFoundation

/// Demo settings. Same role as Android `KinescopeDemoConfig`.
enum KinescopeDemoConfig {
    /// Shorts catalog filter, `GET /v1/videos?project_id=`. `nil` loads every project for the token.
    static let projectId: String? = nil
    /// Optional folder inside that project, `folder_id`. `nil` means any folder.
    static let folderId: String? = nil
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupSDK()
        warmLaunchServices()
        return true
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        guard let root = window?.rootViewController else {
            return .portrait
        }
        return topViewController(from: root).supportedInterfaceOrientations
    }

    private func topViewController(from controller: UIViewController) -> UIViewController {
        if let presented = controller.presentedViewController,
           !presented.isBeingDismissed,
           !(presented is UIAlertController) {
            return topViewController(from: presented)
        }
        if let navigation = controller as? UINavigationController, let visible = navigation.visibleViewController {
            return topViewController(from: visible)
        }
        if let tab = controller as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(from: selected)
        }
        return controller
    }
    
    private func setupSDK() {
        Kinescope.shared.setConfig(.init(apiKey: "bc50167b-e868-47e4-a55c-07208ef15b22"))
        Kinescope.shared.setAnalytics(delegate: self)
        // Every print goes through the debugger console on the calling thread, and the players log constantly.
        // Verbose output is opt-in: add KINESCOPE_VERBOSE=1 to the scheme's environment variables.
        Kinescope.shared.set(logger: KinescopeDefaultLogger(),
                             levels: Self.verbose ? KinescopeLoggerLevel.allCases : [.drm])
    }

    /// Audio session talks to the system audio process. It used to finish before this
    /// method returned, so the launch screen stayed up. The menu is usable before it completes.
    private func warmLaunchServices() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.setupAudioSession()
        }
    }

    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            if #available(iOS 11.0, *) {
                try audioSession.setCategory(
                    AVAudioSession.Category.playback,
                    mode: AVAudioSession.Mode.default,
                    policy: AVAudioSession.RouteSharingPolicy.longForm)
            } else {
                try audioSession.setCategory(.playback)
            }
        } catch {
            Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.player)
        }
    }

}

extension AppDelegate {
    static let verbose = ProcessInfo.processInfo.environment["KINESCOPE_VERBOSE"] != nil
}

extension AppDelegate: KinescopeAnalyticsDelegate {

    func didSendAnalytics(event: String, with data: String) {
        guard Self.verbose else { return }
        debugPrint("Catched analytic event: \(event) with data \(data)")
    }

}
