//
//  GetUsers.swift
//  Intra42
//
//  Created by Felix Maury on 2019-05-25.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation
import SwiftyJSON

extension API42Manager {
    // TODO: Get application API token officialized to make more than 2 requests per second.
    /**
     Gets all users (up to 3 x 100) whose login, first name or last name matches the string.
     */
    func searchUsers(withString string: String, completionHander: @escaping (JSON?, SearchSection) -> Void) {
        let loginURL = "https://api.intra.42.fr/v2/users?search[login]=\(string)&sort=login&page[size]=100"
        let firstNameURL = "https://api.intra.42.fr/v2/users?search[first_name]=\(string)&sort=login&page[size]=100"
        let lastNameURL = "https://api.intra.42.fr/v2/users?search[last_name]=\(string)&sort=login&page[size]=100"
        
        request(url: loginURL) { (responseJSON) in
            completionHander(responseJSON, .username)
        }
        request(url: firstNameURL) { (responseJSON) in
            completionHander(responseJSON, .firstName)
            
            self.request(url: lastNameURL) { (responseJSON) in
                completionHander(responseJSON, .lastName)
            }
        }
    }
}
