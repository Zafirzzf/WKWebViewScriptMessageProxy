//
//  AppDelegate.swift
//  WKWebViewDemo
//
//  Created by 周正飞 on 2019/11/7.
//  Copyright © 2019 周正飞. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.rootViewController = UINavigationController(rootViewController: BaseWebViewController())
        window?.makeKeyAndVisible()
        return true
    }


}

