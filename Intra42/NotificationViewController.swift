//
//  NotificationViewController.swift
//  Intra42
//
//  Created by Felix Maury on 2019-03-22.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController {

    @IBOutlet weak var notificationView: UIView! {
        didSet {
            notificationView.roundCorners(corners: .allCorners, radius: 5.0)
        }
    }
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.dismiss(animated: true)
        }
    }
    
    @objc func tapHandler() {
        self.dismiss(animated: true)
    }
}
