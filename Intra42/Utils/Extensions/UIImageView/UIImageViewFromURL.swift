//
//  UIImageViewFromURL.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-03-01.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

extension UIImageView {
    public func imageFrom(urlString: String, withIndicator: Bool = true, defaultImg: UIImage? = nil) -> URLSessionDataTask? {
        guard let url = URL(string: urlString) else {
            image = defaultImg
            return nil
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
        
        let session = URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard error == nil, let data = data else {
                print("Error downloading image.")
                var image = defaultImg
                if let error = error as NSError?, error.code == NSURLErrorCancelled {
                    print("Image loading cancelled.")
                    image = nil
                } else if urlString.contains("https://cdn.intra.42.fr/users/small_") && urlString.contains(".jpg") {
                    let newUrl = urlString.replacingOccurrences(of: ".jpg", with: ".png")
                    _ = self.imageFrom(urlString: newUrl, withIndicator: withIndicator, defaultImg: defaultImg)
                    return
                }
                DispatchQueue.main.async {
                    activityIndicator.stopAnimating()
                    self.image = image
                }
                return
            }

            DispatchQueue.main.async {
                activityIndicator.stopAnimating()
                self.image = UIImage(data: data) ?? defaultImg
            }
        }
        session.resume()
        return session
    }
}
