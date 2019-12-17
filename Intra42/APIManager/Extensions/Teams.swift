//
//  GetTeam.swift
//  Intra42
//
//  Created by Felix Maury on 2019-06-10.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation
import SwiftyJSON

extension API42Manager {
    /**
     Gets the scale team for the given ID.
     
     - Parameters:
     - id: ID for the team
     - completionHandler: Called with received JSON data.
     */
    func getTeam(withId id: Int, completionHandler: @escaping ([ProjectTeam]) -> Void) {
        let projectURL = baseURL + "teams?filter[id]=\(id)"
        
        request(url: projectURL) { (data) in
            self._parseTeamData(data: data, completionHandler: completionHandler)
        }
    }
    
    /**
     Gets all teams for a user's project.
     
     - Parameters:
     - forUserId: ID of the user.
     - projectId: ID of the project.
     - completionHandler: Called with array of 'ProjectTeam'. Empty if error.
     */
    func getTeam(forUserId id: Int, projectId: Int, completionHandler: @escaping ([ProjectTeam]) -> Void) {
        let projectURL = baseURL + "users/\(id)/teams?filter[project_id]=\(projectId)"

        request(url: projectURL) { (data) in
            self._parseTeamData(data: data, completionHandler: completionHandler)
        }
    }
    
    fileprivate func _parseTeamData(data: JSON?, completionHandler: @escaping ([ProjectTeam]) -> Void) {
        guard let teams = data?.array?.reversed() else {
            completionHandler([])
            return
        }
        print(teams)
        var projectTeams: [ProjectTeam] = []
        for team in teams {
            let id = team["id"].intValue
            let teamName = team["name"].stringValue
            let repoURL = team["repo_url"].string ?? "Not available"
            let finalGrade = team["final_mark"].intValue
            let isValidated = team["validated?"].boolValue
            let status = team["status"].stringValue //"waiting_for_correction", "in_progress", "finished"
            var users: [User] = []
            for user in team["users"].arrayValue {
                let login = user["login"].stringValue
                let id = user["id"].intValue
                if user["leader"].boolValue {
                    users.insert((id, login), at: 0)
                } else {
                    users.append((id, login))
                }
            }
            var closedAt: String?
            if team["closed?"].boolValue {
                let dateString = team["closed_at"].stringValue
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                if let date = dateFormatter.date(from: dateString) {
                    let time = date.getElapsedInterval()
                    closedAt = "Closed \(time)"
                }
            }
            var lockedAt: String?
            if team["locked?"].boolValue {
                let dateString = team["locked_at"].stringValue
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                if let date = dateFormatter.date(from: dateString) {
                    let time = date.getElapsedInterval()
                    lockedAt = "Locked \(time)"
                }
            }
            var evaluations: [Evaluation] = []
            for evaluation in team["scale_teams"].arrayValue.reversed() {
                guard evaluation["corrector"].string == nil else { continue }
                let grade = evaluation["final_mark"].intValue
                let isValidated = grade >= 60 ? true : false
                let correcorName = evaluation["corrector"]["login"].stringValue
                let correctorId = evaluation["corrector"]["id"].intValue
                let dateString = evaluation["filled_at"].stringValue
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                let date = dateFormatter.date(from: dateString) ?? Date()
                let timeAgo = date.getElapsedInterval()
                let comment = evaluation["comment"].stringValue
                let feedback = evaluation["feedback"].stringValue
                let corrector = (correctorId, correcorName)
                
                let newEva = Evaluation(corrector: corrector,
                                        timeAgo: timeAgo,
                                        grade: grade,
                                        isValidated: isValidated,
                                        comment: comment,
                                        feedback: feedback)
                evaluations.append(newEva)
            }
            let projectTeam = ProjectTeam(id: id,
                                          name: teamName,
                                          finalGrade: finalGrade,
                                          isValidated: isValidated,
                                          status: status,
                                          closedAt: closedAt,
                                          lockedAt: lockedAt,
                                          repoURL: repoURL,
                                          users: users,
                                          evaluations: evaluations)
            projectTeams.append(projectTeam)
        }
        print("PROJECT TEAMS")
        print(projectTeams)
        completionHandler(projectTeams)
    }
}
