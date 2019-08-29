//
//  GetProfilePicture.swift
//  Intra42
//
//  Created by Felix Maury on 2019-05-25.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation
import SwiftyJSON

extension API42Manager {
    /**
     Gets the profile picture of specified user as medium sized
     
     Creates UIImage out of data.
     
     - Parameters:
        - login: Login of user
        - completionHandler: Called with the UIImage. "42_default" from assets on error.
     */
    func getProfilePicture(withLogin login: String, completionHandler: @escaping (UIImage?) -> Void) {
        let urlString = "https://cdn.intra.42.fr/users/medium_\(login).jpg"
        let defaultImage = UIImage(named: "42_default")
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { (data, _, error) in
                if let err = error {
                    print("Error downloading image: \(err)")
                    completionHandler(defaultImage)
                    return
                }
                guard let imgData = data, let image = UIImage(data: imgData) else {
                    completionHandler(defaultImage)
                    return
                }
                completionHandler(image)
                }.resume()
        } else {
            completionHandler(defaultImage)
        }
    }
}
