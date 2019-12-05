//
//  GetCoalitions.swift
//  Intra42
//
//  Created by Felix Maury on 2019-05-25.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation
import SwiftyJSON

extension API42Manager {
    /**
     Gets coalition information about the specified user.
     
     Retrieves UIColor, slug name and image url.
     
     - Parameters:
        - id: ID for user to check
        - completionHandler: Called with retrieved data.
        `"default"`, `Colors.intraTeal`, `""` on error.
     */
    func getCoalitionInfo(forUserId id: Int, completionHandler: @escaping (String, UIColor?, String?) -> Void) {
        request(url: baseURL + "users/\(id)/coalitions") { (responseJSON) in
            guard let data = responseJSON, data.isEmpty == false else {
                completionHandler("Unknown", Colors.intraTeal, nil)
                return
            }
            print(data)
            var lowestId = data.arrayValue[0]["id"].intValue
            var hexColor = data.arrayValue[0]["color"].stringValue
            var coaBgURL = data.arrayValue[0]["cover_url"].stringValue
            var coaName = data.arrayValue[0]["name"].stringValue
            
            let piscineCoas = [9, 10, 11, 12]
            for coalition in data.arrayValue {
                let id = coalition["id"].intValue
                if id <= lowestId && !piscineCoas.contains(id) {
                    lowestId = id
                    hexColor = coalition["color"].stringValue
                    coaBgURL = coalition["cover_url"].stringValue
                    coaName = coalition["name"].stringValue
                }
            }
            
            completionHandler(coaName, UIColor(hexRGB: hexColor), coaBgURL)
        }
    }
    
}
