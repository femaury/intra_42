//
//  AchievementsHeaderCell.swift
//  Intra42
//
//  Created by Felix Maury on 2019-03-20.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class AchievementsHeaderCell: UITableViewCell {

    @IBOutlet weak var progressBackground: UIView!
    @IBOutlet weak var progress: UIView!
    @IBOutlet weak var progressLabel: UILabel!
    
    var achievementCount: Int? {
        didSet {
            if let count = achievementCount {
                let percentage = Double(count) / 108.0
                let progressWidth = percentage * Double(progressBackground.frame.width)
                progress.frame = CGRect(x: 0, y: 0, width: progressWidth, height: Double(progressBackground.frame.height))
                progress.roundCorners(corners: [.topLeft, .bottomLeft], radius: 5.0)
                progress.backgroundColor = Colors.intraTeal
                progressBackground.layer.cornerRadius = 5.0
                progressLabel.text = "\(count)/108"
            }
        }
    }
}
