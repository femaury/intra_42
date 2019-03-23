//
//  ProfileHeaderCell.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-03-01.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class ProfileHeaderCell: UITableViewCell {

    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var campusLabel: UILabel!
    @IBOutlet weak var piscineLabel: UILabel!
    
    @IBOutlet weak var levelView: UIView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var progressView: UIView!
    
    @IBOutlet weak var correctionLabel: UILabel!
    @IBOutlet weak var correctionNumberLabel: UILabel!
    
    @IBOutlet weak var walletStackview: UIStackView!
    @IBOutlet weak var walletLabel: UILabel!
    @IBOutlet weak var walletNumberLabel: UILabel!
    
    
    var userProfile: UserProfile? {
        didSet {
            if let coalitionName = API42Manager.shared.coalitionName {
                let image = UIImage(named: "\(coalitionName)_background") ?? UIImage(named: "default_background")
                background.image = image
                background.contentMode = .scaleAspectFill
            }
            if let data = userProfile {
                profilePicture.imageFrom(urlString: data.imageURL)
                profilePicture.contentMode = .scaleAspectFill
                profilePicture.roundFrame()
                profilePicture.layer.borderWidth = 1
                profilePicture.layer.borderColor = UIColor.black.cgColor

                
                let levelRounded = data.level.rounded(.down)
                let levelPercentage = (data.level - levelRounded) * 100
                let levelText = "Level \(Int(levelRounded)) - \(Int(levelPercentage))%"
                levelLabel.text = levelText
                levelView.layer.cornerRadius = 5.0
                levelView.backgroundColor = UIColor.clear.withAlphaComponent(0.7)
                
                let progress = (levelPercentage / 100) * Double(levelView.frame.width)
                progressView.frame = CGRect(x: 0, y: 0, width: progress, height: Double(levelView.frame.height))
                progressView.roundCorners(corners: [.topLeft, .bottomLeft], radius: 5.0)
                progressView.backgroundColor = API42Manager.shared.coalitionColor
                
                fullNameLabel.text = data.fullName
                usernameLabel.text = data.username
                
                if let location = userProfile?.location {
                    locationLabel.text = location
                }
                
                walletLabel.textColor = API42Manager.shared.coalitionColor
                walletNumberLabel.text = "\(data.wallets)₳"
                correctionLabel.textColor = API42Manager.shared.coalitionColor
                correctionNumberLabel.text = String(data.correctionPoints)
                
                campusLabel.text = userProfile?.mainCampusName
                if let piscineMonth = userProfile?.piscineMonth.getPiscineShortMonth(), let piscineYear = userProfile?.piscineYear {
                    piscineLabel.text = "\(piscineMonth) \(piscineYear.suffix(2))"
                } else {
                    piscineLabel.text = nil
                }
            }
        }
    }
}
