//
//  AppDelegate.swift
//  KinescopeExample
//
//  Created by Никита Коробейников on 20.03.2021.
//

import UIKit
import KinescopeSDK
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        setupAudioSession()
        return true
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .allButUpsideDown
    }

    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            if #available(iOS 11.0, *) {
                try audioSession.setCategory(
                    AVAudioSession.Category.playback,
                    mode: AVAudioSession.Mode.default,
                    policy: AVAudioSession.RouteSharingPolicy.longForm,
                    options: AVAudioSession.CategoryOptions([])
                )
            } else {
                try audioSession.setCategory(.playback, options: AVAudioSession.CategoryOptions([]))
            }
        } catch {
            Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.player)
        }
    }

}
