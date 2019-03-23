//
//  AchievementCell.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-03-05.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class AchievementCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var achievementImage: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var achievementIcon: UIImageView!
    
    var isOwned = false
    var achievement: Achievement? {
        didSet {
            if let achievement = self.achievement {
                var title = achievement.name
                if self.isOwned {
                    let count = achievement.subs.count
                    if count > 0 {
                        title += " \(count + 1)"
                    } else if achievement.successCount != 0 && title != "I'm reliable !" {
                        title += " 1"
                    }
                }
                self.titleLabel.text = title
                self.descriptionLabel.text = achievement.description
                self.containerView.layer.borderWidth = 2
                self.containerView.layer.borderColor = achievement.tier.color?.cgColor
                self.achievementImage.backgroundColor = achievement.tier.color
                self.achievementIcon.image = achievement.image
            }
        }
    }
}
