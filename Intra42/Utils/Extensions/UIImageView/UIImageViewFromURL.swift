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
        let urlCache = URLCache.shared
        let request = URLRequest(url: url)
        
        image = nil
        if let data = urlCache.cachedResponse(for: request)?.data {
            self.image = UIImage(data: data) ?? defaultImg
        } else {
            let activityIndicator = UIActivityIndicatorView()
            if withIndicator {
                activityIndicator.center = convert(center, from: superview)
                activityIndicator.hidesWhenStopped = true
                activityIndicator.startAnimating()
                addSubview(activityIndicator)
            }
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard error == nil, let imgData = data else {
                    print("Error downloading image.")
                    DispatchQueue.main.async {
                        activityIndicator.stopAnimating()
                        self.image = defaultImg
                    }
                    return
                }
                if let response = response {
                    let cachedData = CachedURLResponse(response: response, data: imgData)
                    urlCache.storeCachedResponse(cachedData, for: request)
                }
                DispatchQueue.main.async {
                    activityIndicator.stopAnimating()
                    self.image = UIImage(data: imgData) ?? defaultImg
                }
            }.resume()
        }
    }
}
