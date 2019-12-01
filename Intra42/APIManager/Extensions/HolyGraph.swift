//
//  HolyGraph.swift
//  Intra42
//
//  Created by Felix Maury on 2019-12-01.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation
import SwiftyJSON

extension API42Manager {
    
    /**
    Gets all projects and coordinates for holy graph.
    
    Uses 42's private API with the cookie obtained from user login for OAuth.
    */
    func getProjectCoordinates(forUser user: String, campusId: Int, cursusId: Int, completionHandler: @escaping ([JSON]) -> Void) {
        let urlString = "https://projects.intra.42.fr/project_data.json?cursus_id=\(cursusId)&campus_id=\(campusId)&login=\(user)"
        
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, _, error in
                guard error == nil, let data = data else {
                    print("ERROR")
                    return
                }
                guard let valueJSON = try? JSON(data: data) else {
                    print("Request Error: Couldn't get data after request...")
                    API42Manager.shared.showErrorAlert(message: "There was a problem with 42's API...")
                    return
                }
                completionHandler(valueJSON.arrayValue)
            }.resume()
        }
    }
}
