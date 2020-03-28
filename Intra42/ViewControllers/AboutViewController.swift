//
//  AboutViewController.swift
//  Intra42
//
//  Created by Felix Maury on 2019-06-24.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit
import SafariServices
import StoreKit

class AboutViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "About"
        
        // Keeps navbar background color black in iOS 13
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .systemBackground
            navigationItem.standardAppearance = appearance
            navigationItem.scrollEdgeAppearance = appearance
        }

        scrollView.contentSize = contentView.frame.size
        
        if let versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            versionLabel.text = "v\(versionNumber) (\(buildNumber))"
        } else {
            versionLabel.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.view.setNeedsLayout() // force update layout
        navigationController?.view.layoutIfNeeded() // to fix height of the navigation bar
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
    
    @IBAction func openReviewLink(_ sender: UIButton) {
        SKStoreReviewController.requestReview()
    }

    @IBAction func openSwiftyJSONLink(_ sender: UIButton) {
        openSafariController(withURL: "https://github.com/SwiftyJSON/SwiftyJSON")
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
