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
        let scalesURL = baseURL + "me/scale_teams?page[size]=100"
        var corrections: [Correction] = []
        
        request(url: scalesURL) { (data) in
            guard let data = data?.arrayValue, data.count > 0 else {
                completionHandler([])
                return
            }
            for scale in data.reversed() {
                // TODO: Find way to get project ID when team unavailable (not correctee and pre 15 minutes details)
                let team = scale["team"]
                let members = team["users"].arrayValue
                let projectId = team["project_id"].int
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
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                let date = dateFormatter.date(from: dateString) ?? Date()
                
                if let id = projectId {
                    self.getProject(withId: id, completionHandler: { (projData) in
                        var name = "Unknown Project"
                        if let projData = projData, let projName = projData["name"].string {
                            name = projName.capitalized
                        }
                        
                        let correction = Correction(
                            name: name,
                            team: (teamId, teamName),
                            projectId: id,
                            repoURL: repoURL,
                            isCorrector: isCorrector,
                            corrector: corrector,
                            correctees: correctees,
                            startDate: date)
                        
                        corrections.append(correction)
                        completionHandler(corrections)
                    })
                } else {
                    let correction = Correction(
                        name: "Unknown Project",
                        team: (teamId, teamName),
                        projectId: -1,
                        repoURL: repoURL,
                        isCorrector: isCorrector,
                        corrector: corrector,
                        correctees: correctees,
                        startDate: date)
                    
                    corrections.append(correction)
                    completionHandler(corrections)
                }
            }
        }
    }
}
