//
//  SideMenuCaller.swift
//  Intra42
//
//  Created by Felix Maury on 26/03/2020.
//  Copyright © 2020 Felix Maury. All rights reserved.
//

import UIKit

protocol SideMenuCaller: UIViewController {
    
    func showSideMenu()
}

extension SideMenuCaller {
    
    func showSideMenu() {
        let storyboard = UIStoryboard(name: "SideMenu", bundle: nil)
        guard let sideMenuVC = storyboard.instantiateViewController(withIdentifier: "SideMenuController")
            as? SideMenuController else {
                assertionFailure("No view controller ID SideMenuController in storyboard")
                return
        }
        UIApplication.shared.keyWindow?.endEditing(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            sideMenuVC.menuNavigationController = self.navigationController
            sideMenuVC.snapshotForBackground = self.tabBarController?.view.asImage()
            sideMenuVC.modalPresentationStyle = .fullScreen
            self.present(sideMenuVC, animated: false, completion: nil)
        }
    }
}
