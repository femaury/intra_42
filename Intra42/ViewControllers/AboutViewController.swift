//
//  AboutViewController.swift
//  Intra42
//
//  Created by Felix Maury on 2019-06-24.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit
import SafariServices

class AboutViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.contentSize = contentView.frame.size
    }
    
    func openSafariController(withURL url: String) {
        if let url = URL(string: url) {
            let safariVC = SFSafariViewController(url: url)
            safariVC.modalPresentationStyle = .overFullScreen
            self.present(safariVC, animated: true, completion: nil)
        }
    }

    @IBAction func openAndroidLink(_ sender: UIButton) {
        openSafariController(withURL: "https://github.com/pvarry/intra42")
    }

    @IBAction func openGithubLink(_ sender: UIButton) {
        openSafariController(withURL: "https://github.com/femaury/intra_42")
    }
    
    @IBAction func openPaypalLink(_ sender: UIButton) {
        openSafariController(withURL: "https://paypal.me/femaurydev")
    }

    @IBAction func openSwiftyJSONLink(_ sender: UIButton) {
        openSafariController(withURL: "https://github.com/SwiftyJSON/SwiftyJSON")
    }

    @IBAction func openSideMenuLink(_ sender: UIButton) {
        openSafariController(withURL: "https://github.com/jonkykong/SideMenu")
    }

    @IBAction func openSVGKitLink(_ sender: UIButton) {
        openSafariController(withURL: "https://github.com/SVGKit/SVGKit")
    }

    @IBAction func openKeychainSwiftLink(_ sender: UIButton) {
        openSafariController(withURL: "https://github.com/evgenyneu/keychain-swift")
    }

    @IBAction func openCrashlyticsLink(_ sender: UIButton) {
        openSafariController(withURL: "https://get.fabric.io/")
    }
}
