//
//  AppDelegate.swift
//  KinescopeExample
//
//  Created by Никита Коробейников on 20.03.2021.
//

import UIKit
import KinescopeSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Kinescope.shared.setConfig(.init(apiKey: "stub"))
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        return true
    }

}
