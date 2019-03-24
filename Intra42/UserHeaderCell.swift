//
//  UserHeaderCell.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-03-04.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class UserHeaderCell: UITableViewCell {
    
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var campusLabel: UILabel!
    @IBOutlet weak var piscineLabel: UILabel!
    
    @IBOutlet weak var levelView: UIView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var levelLabel: UILabel!
    
    @IBOutlet weak var walletLabel: UILabel!
    @IBOutlet weak var walletNumberLabel: UILabel!
    @IBOutlet weak var correctionLabel: UILabel!
    @IBOutlet weak var correctionNumberLabel: UILabel!
    
    var userId: Int?
    var phoneNumber: String?
    var emailAddress: String?
    
    var coalitionColor: UIColor?
    var coalitionLogo: String?
    var coalitionName: String?
    
    weak var delegate: UserProfileController?
    weak var userProfile: UserProfile? {
        didSet {
            if let coalitionName = self.coalitionName {
                let image = UIImage(named: "\(coalitionName)_background") ?? UIImage(named: "default_background")
                background.image = image
                background.contentMode = .scaleAspectFill
            }
            if let data = userProfile {
                profilePicture.imageFrom(urlString: data.imageURL)
                profilePicture.contentMode = .scaleAspectFill
                profilePicture.layer.borderWidth = 1
                profilePicture.layer.masksToBounds = false
                profilePicture.layer.borderColor = UIColor.black.cgColor
                profilePicture.layer.cornerRadius = profilePicture.frame.height / 2
                profilePicture.clipsToBounds = true
                
                let levelRounded = data.level.rounded(.down)
                let levelPercentage = (data.level - levelRounded) * 100
                let levelText = "Level \(Int(levelRounded)) - \(Int(levelPercentage))%"
                levelLabel.text = levelText
                levelView.layer.cornerRadius = 5.0
                levelView.backgroundColor = UIColor.clear.withAlphaComponent(0.7)
                
                let progress = (levelPercentage / 100) * Double(levelView.frame.width)
                progressView.frame = CGRect(x: 0, y: 0, width: progress, height: Double(levelView.frame.height))
                progressView.roundCorners(corners: [.topLeft, .bottomLeft], radius: 5.0)
                progressView.backgroundColor = coalitionColor
                
                fullNameLabel.text = data.fullName
                usernameLabel.text = data.username
                
                walletLabel.textColor = coalitionColor
                walletNumberLabel.text = "\(data.wallets)₳"
                correctionLabel.textColor = coalitionColor
                correctionNumberLabel.text = String(data.correctionPoints)
                
                userId = userProfile?.userId
                phoneNumber = userProfile?.phoneNumber
                emailAddress = userProfile?.email
                
                if let location = userProfile?.location {
                    locationLabel.text = location
                }
                campusLabel.text = userProfile?.mainCampusName
                if let piscineMonth = userProfile?.piscineMonth.getPiscineShortMonth(), let piscineYear = userProfile?.piscineYear {
                    piscineLabel.text = "\(piscineMonth) \(piscineYear.suffix(2))"
                } else {
                    piscineLabel.text = nil
                }
            }
        }
    }
    
    @IBAction func callUser(_ sender: UIButton) {
        guard let delegate = self.delegate else { return }
        delegate.callUser()
    }
    
    @IBAction func emailUser(_ sender: UIButton) {
        guard let delegate = self.delegate else { return }
        delegate.emailUser()
    }
}
