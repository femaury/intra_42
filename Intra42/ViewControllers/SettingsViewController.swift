//
//  SettingsViewController.swift
//  Intra42
//
//  Created by Felix Maury on 2019-07-06.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var appearanceView: UIView!
    
    @IBOutlet weak var appIconImages: UIStackView!
    @IBOutlet weak var primaryColorButtons: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fixes navbar background color bug in iOS 13
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .systemBackground
            navigationItem.standardAppearance = appearance
            navigationItem.scrollEdgeAppearance = appearance
        }

        appearanceView.layer.borderWidth = 1
        appearanceView.layer.borderColor = UIColor.lightGray.cgColor
        for case let button as UIButton in primaryColorButtons.arrangedSubviews {
            button.roundCorners(corners: .allCorners, radius: 25)
        }
        for case let icon as UIImageView in appIconImages.arrangedSubviews {
            icon.roundCorners(corners: .allCorners, radius: 5)
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectIcon(gesture:)))
            icon.isUserInteractionEnabled = true
            icon.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.view.setNeedsLayout() // force update layout
        navigationController?.view.layoutIfNeeded() // to fix height of the navigation bar
    }
    
    @objc func selectIcon(gesture: UITapGestureRecognizer) {
        guard let image = gesture.view as? UIImageView else { return }
        switch image.tag {
        case 1:
            UIApplication.shared.setAlternateIconName("AppIconAll")
        case 2:
            UIApplication.shared.setAlternateIconName("AppIconAss")
        case 3:
            UIApplication.shared.setAlternateIconName("AppIconFed")
        case 4:
            UIApplication.shared.setAlternateIconName("AppIconOrd")
        default:
            UIApplication.shared.setAlternateIconName(nil)
        }
    }
    
    func setColorTo(_ color: UIColor?) {
        
        self.tabBarController?.tabBar.tintColor = color
        
        if let children = self.tabBarController?.children {
            for child in children {
                guard let navController = child as? UINavigationController else { continue }
                navController.navigationBar.tintColor = color
            }
        }
    }
    
    @IBAction func changeColor(sender: UIButton) {
        switch sender.tag {
        case 1:
            let color = Colors.Coalitions.all
            API42Manager.shared.preferedPrimaryColor = color
            setColorTo(color)
        case 2:
            let color = Colors.Coalitions.ass
            API42Manager.shared.preferedPrimaryColor = color
            setColorTo(color)
        case 3:
            let color = Colors.Coalitions.fed
            API42Manager.shared.preferedPrimaryColor = color
            setColorTo(color)
        case 4:
            let color = Colors.Coalitions.ord
            API42Manager.shared.preferedPrimaryColor = color
            setColorTo(color)
        default:
            let color = Colors.intraTeal
            API42Manager.shared.preferedPrimaryColor = color
            setColorTo(color)
        }
    }
}
