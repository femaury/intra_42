//
//  UIImageViewFromURL.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-03-01.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

extension UIImageView {
    public func imageFrom(urlString: String, withIndicator: Bool = true, defaultImg: UIImage? = nil) {
        guard let url = URL(string: urlString) else {
            image = defaultImg
            return
        }
        let request = URLRequest(url: url)
        
        image = nil
        let activityIndicator = UIActivityIndicatorView()
        if withIndicator {
            activityIndicator.center = convert(center, from: superview)
            activityIndicator.hidesWhenStopped = true
            activityIndicator.startAnimating()
            addSubview(activityIndicator)
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard error == nil, let data = data else {
                print("Error downloading image.")
                DispatchQueue.main.async {
                    activityIndicator.stopAnimating()
                    self.image = defaultImg
                }
                return
            }

            DispatchQueue.main.async {
                activityIndicator.stopAnimating()
                self.image = UIImage(data: data) ?? defaultImg
            }
        }.resume()
    }
}
