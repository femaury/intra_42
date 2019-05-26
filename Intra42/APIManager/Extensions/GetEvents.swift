//
//  GetEvents.swift
//  Intra42
//
//  Created by Felix Maury on 2019-05-25.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation
import SwiftyJSON

extension API42Manager {
    /**
     Gets future events (up to 100) for specified campus and cursus.
     
     - Parameters:
        - campusId: ID for campus to check for events
        - cursusId: ID for the cursus to check for events
        - completionHandler: Called with array of returned JSON value. Empty on error.
     */
    func getFutureEvents(forCampusId campusId: Int, cursusId: Int, completionHandler: @escaping ([JSON]) -> Void) {
        let eventsURL = "https://api.intra.42.fr/v2/campus/\(campusId)/cursus/\(cursusId)/events?filter[future]=true&page[size]=100"
        
        request(url: eventsURL) { (eventsData) in
            guard let eventsData = eventsData else {
                completionHandler([])
                return
            }
            print(eventsData)
            completionHandler(eventsData.arrayValue)
        }
    }
    
    /**
     Gets future events (up to 100) for specified user (subscribed).
     
     - Parameters:
     - userId: ID for user to check for events
     - completionHandler: Called with array of returned JSON value. Empty on error.
     */
    func getFutureEvents(forUserId id: Int, completionHandler: @escaping ([JSON]) -> Void) {
        let eventsURL = "https://api.intra.42.fr/v2/users/\(id)/events?filter[future]=true&page[size]=100"
        
        request(url: eventsURL) { (eventsData) in
            guard let eventsData = eventsData else {
                completionHandler([])
                return
            }
            completionHandler(eventsData.arrayValue)
        }
    }
}
