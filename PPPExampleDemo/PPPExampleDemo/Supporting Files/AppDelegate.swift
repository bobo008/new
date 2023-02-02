//
//  AppDelegate.swift
//  PPPExampleDemo
//
//  Created by tanghongbo on 2022/12/14.
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

