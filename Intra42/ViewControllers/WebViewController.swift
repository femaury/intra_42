//
//  WebViewController.swift
//  Intra42
//
//  Created by Felix Maury on 2019-11-27.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        webView.isOpaque = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    func load(_ urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
            self.title = webView.url?.host
        }
    }
    
    @IBAction func pressCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        let navType = navigationAction.navigationType

        if navType == .formSubmitted || navType == .other {
            if let url = navigationAction.request.url {
                if url.host == "oauth2callback" {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    decisionHandler(.cancel)
                    return
                }
                decisionHandler(.allow)
                return
            }
        }
        decisionHandler(.cancel)
    }
}
