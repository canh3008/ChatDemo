//
//  AppDelegate.swift
//  ChatDemo
//
//  Created by Duc Canh on 16/04/2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        initRootView()
        return true
    }
}

extension AppDelegate {
    func initRootView() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ConversationsViewController()
        window?.makeKeyAndVisible()
    }
}
