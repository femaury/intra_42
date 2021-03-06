//
//  Achievement.swift
//  Intra42
//
//  Created by Felix Maury on 2019-03-19.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import SVGKit

class Achievement {
    static let MoscowAchievementIds = [129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 165, 166, 167, 190]
    
    var id: Int
    var name: String
    var description: String
    var tier: AchievementTier
    var kind: AchievementKind
    var successCount: Int
    var imageURL: String
    var image: UIImage?
    var subs: [Achievement]
    var usersURL: String
    
    init(achievement: JSON) {
        self.id = achievement["id"].intValue
        self.name = achievement["name"].stringValue
        self.description = achievement["description"].stringValue
        let tierString = achievement["tier"].stringValue
        self.tier = AchievementTier(rawValue: tierString) ?? .none
        let kindString = achievement["kind"].stringValue
        self.kind = AchievementKind(rawValue: kindString) ?? .project
        self.successCount = achievement["nbr_of_success"].intValue
        self.subs = []
        self.usersURL = achievement["users_url"].stringValue
        self.image = UIImage(named: "help")
        if let path = achievement["image"].string {
            self.imageURL = "https://api.intra.42.fr\(path)"
            if let url: URL = URL(string: imageURL) {
                URLSession.shared.dataTask(with: url) { (data, _, error) in
                    guard error == nil, let imgData = data else { return }
                    self.image = SVGKImage(data: imgData)?.uiImage
                }.resume()
            }
        } else {
            self.imageURL = ""
        }
    }
}
