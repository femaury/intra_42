//
//  UserProfile.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-02-28.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import SVGKit

struct Project {
    var name: String
    var finished: Date?
    var grade: Int
    var validated: Bool
    var retries: Int
    var piscineDays: [Project]?
}

class UserProfile {
    
    var cursusUsers: [JSON]
    var projectsUsers: [JSON]
    
    var userId: Int = 0
    var username: String
    var fullName: String
    var imageURL: String
    var isStaff: Bool
    var phoneNumber: String
    var email: String
    var wallets: Int
    var correctionPoints: Int
    var level: Double = 0
    
    var piscineMonth: String
    var piscineYear: String
    
    var mainCursusID: Int = 1
    var mainCursusName: String = ""
    var cursusList: [(id: Int, name: String)] = []
    
    var mainCampusID: Int = 1
    var mainCampusName: String = ""
    var campusList: [(id: Int, name: String)] = []
    
    var projects: [Project] = []
    var skills: [(name: String, level: Double)] = []
    var locationLogs: [LocationLog] = []
    
    var achievements: [String : Achievement] = [:]
    var achievementsCount: Int = 0
    var achievementsIndices: [String] = []
    
    var location: String?
    
    init(data: JSON) {
        username = data["login"].stringValue
        fullName = data["displayname"].stringValue
        imageURL = data["image_url"].stringValue
        isStaff = data["staff?"].boolValue
        phoneNumber = data["phone"].stringValue
        email = data["email"].stringValue
        wallets = data["wallet"].intValue
        correctionPoints = data["correction_point"].intValue
        piscineMonth = data["pool_month"].stringValue
        piscineYear = data["pool_year"].stringValue
        
        location = data["location"].string
        
        let projects = data["projects_users"].arrayValue
        projectsUsers = projects
        let cursuses = data["cursus_users"].arrayValue
        cursusUsers = cursuses
        var cursusID: Int = 1
        if cursuses.count > 0 {
            for cursus in cursuses {
                let info = cursus["cursus"]
                let name = info["name"].stringValue
                let id = info["id"].intValue
                if cursus["grade"].string != nil || cursuses.count == 1 {
                    mainCursusID = id
                    mainCursusName = name
                    cursusID = id
                }
                cursusList.append((id, name))
            }
        }
        
        let campusUsers = data["campus_users"].arrayValue
        var primaryID = 1
        for campus in campusUsers {
            if campus["is_primary"].boolValue == true {
                primaryID = campus["campus_id"].intValue
                break
            }
        }
        
        let campuses = data["campus"].arrayValue
        for campus in campuses {
            let id = campus["id"].intValue
            let name = campus["name"].stringValue
            if id == primaryID {
                mainCampusID = id
                mainCampusName = name
            }
            campusList.append((id, name))
        }
        
        // Compute achievements in prioritized thread other than main (saves loading time)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let achievements = data["achievements"].arrayValue
            for achievement in achievements {
                self.achievementsCount += 1
                let newAchievement = Achievement(achievement: achievement)
                let name = newAchievement.name
                if let parent = self.achievements[name] {
                    if parent.successCount < newAchievement.successCount {
                        newAchievement.subs += parent.subs
                        parent.subs = []
                        newAchievement.subs.append(parent)
                        self.achievements[name] = newAchievement
                    } else {
                        parent.subs.append(newAchievement)
                    }
                } else {
                    self.achievements[name] = newAchievement // TODO: Fix small leak???
                    self.achievementsIndices.append(name)
                }
            }
        }
        getLevelAndSkills(cursusID: cursusID)
        getProjects(cursusID: cursusID)
        API42Manager.shared.getLogsForUserWith(id: self.userId) { [weak self] (locationLogs) in
            guard let self = self else { return }
            self.locationLogs = locationLogs
        }
    }
    
    func getLevelAndSkills(cursusID: Int) {
        skills = []
        for cursus in cursusUsers {
            if cursus["cursus_id"].int == cursusID {
                self.level = cursus["level"].doubleValue
                self.userId = cursus["user"]["id"].intValue
                for skill in cursus["skills"].arrayValue {
                    if let name = skill["name"].string, let level = skill["level"].double {
                        self.skills.append((name, level))
                    }
                }
                break
            }
        }
    }
    
    func getProjects(cursusID: Int) {
        projects = []
        for project in projectsUsers {
            if project["cursus_ids"].arrayValue.map({$0.int}).contains(cursusID) {
                let info = project["project"]
                if info["parent_id"] != JSON.null { continue }
                
                let piscineID = info["id"].intValue
                let piscineDays = getPiscineDays(projectsArray: projectsUsers, cursusID: cursusID, piscineID: piscineID)
                
                if let dateString = project["marked_at"].string {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                    let date = dateFormatter.date(from: dateString)
                    
                    let newProject = Project(
                        name: info["name"].stringValue,
                        finished: date,
                        grade: project["final_mark"].intValue,
                        validated: project["validated?"].boolValue,
                        retries: project["occurence"].intValue,
                        piscineDays: piscineDays.isEmpty ? nil : piscineDays
                    )
                    self.projects.append(newProject)
                }
            }
        }
    }
    
    func getPiscineDays(projectsArray: [JSON], cursusID: Int, piscineID: Int) -> [Project] {
        var piscineDays: [Project] = []

        for subProject in projectsArray {
            if subProject["cursus_ids"].arrayValue.map({$0.int}).contains(cursusID) {
                let info = subProject["project"]
                if info["parent_id"].intValue == piscineID {
                    let dateString = subProject["marked_at"].stringValue
                    let dateFormatter = DateFormatter()
                    let date = dateFormatter.date(from: dateString)
                    
                    let newProject = Project(
                        name: info["name"].stringValue,
                        finished: date,
                        grade: subProject["final_mark"].intValue,
                        validated: subProject["validated?"].boolValue,
                        retries: subProject["occurence"].intValue,
                        piscineDays: nil
                    )
                    piscineDays.append(newProject)
                }
            }
        }
        return piscineDays
    }
}
