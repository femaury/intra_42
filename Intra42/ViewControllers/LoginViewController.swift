//
//  LoginViewController.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-02-27.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit
import WebKit

class LoginViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var errorLabel: UILabel!
    var errorMessage: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorLabel.isHidden = true
        API42Manager.shared.oAuthTokenCompletionHandler = { error in
            if let err = error {
                print(err)
                self.errorMessage = "Couldn't login with OAuth..."
                return
            }
            self.performSegue(withIdentifier: "loginSegue", sender: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let error = errorMessage else { return }
        errorLabel.text = error
        errorLabel.isHidden = false
    }

    @IBAction func connectButton(_ sender: UIButton) {
        API42Manager.shared.startOAuth2Login()
    }
}
