//
//  UIImageViewFromURL.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-03-01.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

extension UIImageView {
    public func imageFrom(urlString: String, withIndicator: Bool = true) {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = convert(center, from: superview)
        activityIndicator.hidesWhenStopped = true
        if withIndicator {
            activityIndicator.startAnimating()
            self.addSubview(activityIndicator)
        }
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { (data, _, error) in
                if let err = error {
                    print("Error downloading image: \(err)")
                    DispatchQueue.main.async {
                        activityIndicator.stopAnimating()
                    }
                    return
                }
                guard let imgData = data else {
                    DispatchQueue.main.async {
                        activityIndicator.stopAnimating()
                    }
                    return
                }
                DispatchQueue.main.async {
                    activityIndicator.stopAnimating()
                    self.image = UIImage(data: imgData)
                }
            }.resume()
        }
    }
}
