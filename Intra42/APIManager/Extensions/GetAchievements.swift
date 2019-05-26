//
//  GetAchievements.swift
//  Intra42
//
//  Created by Felix Maury on 2019-05-25.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation
import SwiftyJSON

extension API42Manager {
    /**
     Gets all possible achievements.
     
     Parses the returned JSON data into a dictionary of [String: Achievement].
     Keeps count of children/parent relations between achievements and always
     keeps the parents at top level.
     
     - Parameter completionHandler: Closure called with all achievements. Empty on errors.
     */
    func getAllAchievements(completionHandler: @escaping ([String: Achievement]) -> Void) {
        let achievementsURL = "https://api.intra.42.fr/v2/achievements?page[size]=100"
        
        request(url: achievementsURL) { (data) in
            guard let data = data else {
                completionHandler([:])
                return
            }
            var achievementsData = data.arrayValue
            if achievementsData.count == 100 {
                let page2URL = achievementsURL + "&page[number]=2"
                
                self.request(url: page2URL, completionHandler: { (data) in
                    guard let data = data else {
                        self.parseAchievementsData(achievementsData, completionHandler)
                        return
                    }
                    achievementsData += data.arrayValue
                    self.parseAchievementsData(achievementsData, completionHandler)
                })
            } else {
                self.parseAchievementsData(achievementsData, completionHandler)
            }
        }
    }
    
    fileprivate func parseAchievementsData(_ data: [JSON], _ completionHandler: ([String: Achievement]) -> Void) {
        var achievements: [String: Achievement] = [:]
        
        for achievement in data {
            if Achievement.MoscowAchievementIds.contains(achievement["id"].intValue) { continue }
            let newAchievement = Achievement(achievement: achievement)
            let name = newAchievement.name
            if let parent = achievements[name] {
                if parent.successCount > newAchievement.successCount {
                    newAchievement.subs += parent.subs
                    parent.subs = []
                    newAchievement.subs.append(parent)
                    achievements.updateValue(newAchievement, forKey: name)
                } else {
                    parent.subs.append(newAchievement)
                }
            } else {
                achievements.updateValue(newAchievement, forKey: name)
            }
        }
        completionHandler(achievements)
        self.allAchievements = achievements
    }
}
