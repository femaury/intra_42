//
//  GetLocations.swift
//  Intra42
//
//  Created by Felix Maury on 2019-05-25.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation
import SwiftyJSON

extension API42Manager {
    /**
     Gets all logged in users and their locations for specified campus.
     
     Recursive function getting all logged in users by incrementing the page
     parameter.
     
     - Parameters:
        - id: ID for campus to check locations for
        - page: Page number to start recursion. Should be 1 to get all users.
        - completionHandler: Called with array of received JSON data.
     */
    func getLocations(forCampusId id: Int, page: Int, completionHandler: @escaping ([JSON]) -> Void) {
        let locationURL = "https://api.intra.42.fr/v2/campus/\(id)/locations?filter[active]=true&page[number]=\(page)&page[size]=100"
        
        request(url: locationURL) { (data) in
            guard let data = data  else {
                completionHandler([])
                return
            }
            self.locationData += data.arrayValue
            if data.arrayValue.count == 100 {
                print("Location Page \(page)")
                self.getLocations(forCampusId: id, page: page + 1, completionHandler: completionHandler)
            } else {
                completionHandler(self.locationData)
                self.locationData = []
            }
        }
    }
}
