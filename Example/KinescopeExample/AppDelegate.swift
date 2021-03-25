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

        // FIXME: Remove when start KIN-28
        let users = ConfigStorage.read()
        let surfUser = users.first(where: { $0.name == "surf" })
        Kinescope.shared.setConfig(.init(apiKey: surfUser!.apiKey))

        Kinescope.shared.inspector.list(request: .init(page: 1),
                                        onSuccess: { result in
                                            print("KIN list result: \(result)")
                                        }, onError: { error in
                                            print("KIN list error: \(error)")
                                        })

        return true
    }

}
