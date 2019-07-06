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
    
    @IBAction func changeColor(sender: UIButton) {
        switch sender.tag {
        case 1:
            print("1")
        case 2:
            print("2")
        case 3:
            print("3")
        case 4:
            print("4")
        default:
            print("default")
        }
    }
}
