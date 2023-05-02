//
//  AppDelegate.swift
//  ChatDemo
//
//  Created by Duc Canh on 16/04/2023.
//

import UIKit
import FirebaseCore
import FBSDKLoginKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        initRootView()
        ApplicationDelegate.shared.application(
                    application,
                    didFinishLaunchingWithOptions: launchOptions)
        return true
    }

    func application(
            _ app: UIApplication,
            open url: URL,
            options: [UIApplication.OpenURLOptionsKey: Any] = [:]
        ) -> Bool {
            ApplicationDelegate.shared.application(
                app,
                open: url,
                sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        }
}

extension AppDelegate {
    func initRootView() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = CommonTabBarViewController()
        window?.makeKeyAndVisible()
    }
}
