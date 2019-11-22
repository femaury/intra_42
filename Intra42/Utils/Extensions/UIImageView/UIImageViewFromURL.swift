//
//  UIImageViewFromURL.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-03-01.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

extension UIImageView {
    public func imageFrom(urlString: String) {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            activityIndicator.style = .medium
        } else {
            activityIndicator.style = .white
        }
        activityIndicator.startAnimating()
        self.addSubview(activityIndicator)
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { (data, _, error) in
                if let err = error {
                    print("Error downloading image: \(err)")
                    return
                }
                guard let imgData = data else { return }
                DispatchQueue.main.async {
                    activityIndicator.stopAnimating()
                    self.image = UIImage(data: imgData)
                }
            }.resume()
        }
    }
}
