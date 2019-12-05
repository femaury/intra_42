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
    // first_name and last_name have been removed from search parameter (27/08/19)
    // now searching for full names instead...
    /**
     Gets all users (up to 3 x 100) whose login, first name or last name matches the string.
     */
    func searchUsers(withString string: String, completionHander: @escaping (JSON?, SearchSection) -> Void) {
        let loginURL = baseURL + "users?search[login]=\(string)&sort=login&page[size]=100"
        let firstURL = baseURL + "users?filter[first_name]=\(string)&sort=login&page[size]=100"
        let lastURL = baseURL + "users?filter[last_name]=\(string)&sort=login&page[size]=100"

//        let firstNameURL = baseURL + "users?search[first_name]=\(string)&sort=login&page[size]=100"
//        let lastNameURL = baseURL + "users?search[last_name]=\(string)&sort=login&page[size]=100"

        request(url: loginURL) { (responseJSON) in
            completionHander(responseJSON, .username)

            self.request(url: firstURL) { (responseJSON) in
                completionHander(responseJSON, .firstName)
                
                self.request(url: lastURL) { (responseJSON) in
                    completionHander(responseJSON, .lastName)
                }
            }
        }

//        request(url: firstNameURL) { (responseJSON) in
//            completionHander(responseJSON, .firstName)
//
//            self.request(url: lastNameURL) { (responseJSON) in
//                completionHander(responseJSON, .lastName)
//            }
//        }
    }
}
