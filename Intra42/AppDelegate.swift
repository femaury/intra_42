//
//  AppDelegate.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-02-26.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit
import SideMenu
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])

        SideMenuManager.default.menuPresentMode = .menuSlideIn
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuAnimationFadeStrength = 0.2

        self.window?.backgroundColor = UIColor.white

        let homeController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomeTabBarController")
        for child in homeController.children {
            guard let navController = child as? UINavigationController else { continue }
            navController.navigationBar.tintColor = Colors.intraTeal
        }

        if API42Manager.shared.hasOAuthToken() == true {
            self.window?.rootViewController = homeController
        }
        return true
    }

    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        API42Manager.shared.processOAuthResponse(url)
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        FriendDataManager.shared.coreData.saveContext()
    }
}
