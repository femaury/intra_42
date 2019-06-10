//
//  GetScales.swift
//  Intra42
//
//  Created by Felix Maury on 2019-05-25.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation
import SwiftyJSON

extension API42Manager {
    /**
     Gets all current scales (corrections) for the logged in user
     
     Parses the received JSON data into `Correction` objects.
     
     - Parameter completionHandler: Called with array of `Correction`.
        Empty on error.
     */
    func getScales(completionHandler: @escaping ([Correction]) -> Void) {
        let scalesURL = "https://api.intra.42.fr/v2/me/scale_teams?page[size]=100"
        var corrections: [Correction] = []
        
        request(url: scalesURL) { (data) in
            guard let data = data?.array else {
                completionHandler([])
                return
            }
            for scale in data.reversed() {
                let team = scale["team"]
                let members = team["users"].arrayValue
                let projectId = team["project_id"].intValue
                let repoURL = team["repo_url"].stringValue
                let teamName = team["name"].stringValue
                let teamId = team["id"].intValue
                
                var correctees: [User] = []
                var isCorrector = true
                for member in members {
                    let correcteeLogin = member["login"].stringValue
                    let correcteeId = member["id"].intValue
                    if correcteeId == API42Manager.shared.userProfile?.userId {
                        isCorrector = false
                    }
                    if member["leader"].boolValue {
                        correctees.insert((correcteeId, correcteeLogin), at: 0)
                    } else {
                        correctees.append((correcteeId, correcteeLogin))
                    }
                }
                
                var corrector: User = (-1, "Someone")
                if scale["corrector"].string == nil {
                    let corr = scale["corrector"]
                    corrector = (corr["id"].intValue, corr["login"].stringValue)
                }
                
                let dateString = scale["begin_at"].stringValue
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                let date = dateFormatter.date(from: dateString) ?? Date()
                
                self.getProject(withId: projectId, completionHandler: { (data) in
                    var name = "Unknown Project"
                    if let data = data {
                        name = data["name"].stringValue.capitalized
                    }
                    
                    let correction = Correction(
                        name: name,
                        team: (teamId, teamName),
                        projectId: projectId,
                        repoURL: repoURL,
                        isCorrector: isCorrector,
                        corrector: corrector,
                        correctees: correctees,
                        startDate: date)
                    corrections.append(correction)
                    //                    if corrections.count == data?.count {
                    completionHandler(corrections)
                    //                    }
                })
            }
        }
    }
}
