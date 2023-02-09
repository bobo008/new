//
//  AppDelegate.swift
//  newGPUImageDemo
//
//  Created by narwal on 2023/2/9.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)


        let vc = THBMainVC()
        let navigationController = UINavigationController.init(rootViewController: vc)
        if let window = window {
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
        
        return true
    }

}

