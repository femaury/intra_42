//
//  WebViewController.swift
//  Intra42
//
//  Created by Felix Maury on 2019-11-27.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate, UINavigationBarDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var navBarTitle: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        webView.isOpaque = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func load(_ urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
            navBarTitle.title = webView.url?.host
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
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.top
    }
}
