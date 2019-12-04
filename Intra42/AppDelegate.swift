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
        
        let color = API42Manager.shared.preferedPrimaryColor

        let homeController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomeTabBarController")
        for child in homeController.children {
            guard let navController = child as? UINavigationController else { continue }
            navController.navigationBar.tintColor = color ?? Colors.intraTeal
            if #available(iOS 13.0, *) {
                let appearance = UINavigationBarAppearance()
                appearance.backgroundColor = .systemBackground
                navController.navigationItem.standardAppearance = appearance
                navController.navigationItem.scrollEdgeAppearance = appearance
            }
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
