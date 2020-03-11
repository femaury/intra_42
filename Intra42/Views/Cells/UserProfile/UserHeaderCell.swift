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
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var mailButton: UIButton!
    
    @IBOutlet weak var levelView: UIView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var levelLabel: UILabel!
    
    @IBOutlet weak var pointsStackView: UIStackView!
    @IBOutlet weak var walletLabel: UILabel!
    @IBOutlet weak var walletNumberLabel: UILabel!
    @IBOutlet weak var correctionLabel: UILabel!
    @IBOutlet weak var correctionNumberLabel: UILabel!
    
    var userId: Int?
    var phoneNumber: String?
    var emailAddress: String?
    
    var coalitionColor: UIColor?
    var coalitionBgURL: String?
    var coalitionName: String?
    
    var imageSession: URLSessionDataTask?
    var backgroundImageSession: URLSessionDataTask?
    
    weak var delegate: UserProfileController?
    weak var userProfile: UserProfile? {
        didSet {
            if let url = self.coalitionBgURL {
                backgroundImageSession = background.imageFrom(urlString: url, withIndicator: false)
            } else {
                background.image = UIImage(named: "default_background")
            }
            background.contentMode = .scaleAspectFill
            if let data = userProfile {
                imageSession = profilePicture.imageFrom(urlString: data.imageURL)
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
                
                userId = data.userId
                phoneNumber = data.phoneNumber
                
                if phoneNumber == "hidden" {
                    phoneButton.isEnabled = false
                } else {
                    phoneButton.isEnabled = true
                }
                
                emailAddress = data.email
                
                if let location = data.location {
                    locationLabel.text = location
                }
                campusLabel.text = data.mainCampusName
                if data.isStaff {
                    piscineLabel.text = "STAFF"
                    piscineLabel.backgroundColor = .black
                    piscineLabel.roundCorners(corners: .allCorners, radius: 5.0)
                    piscineLabel.textAlignment = .center
                } else {
                    if let piscineMonth = data.piscineMonth.getPiscineShortMonth() {
                        let piscineYear = data.piscineYear
                        piscineLabel.text = "\(piscineMonth) \(piscineYear.suffix(2))"
                    } else {
                        piscineLabel.text = nil
                    }
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profilePicture.image = nil
        background.image = nil
        imageSession?.cancel()
        backgroundImageSession?.cancel()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        for (index, view) in pointsStackView.arrangedSubviews.enumerated() where index == 1 {
            pointsStackView.setCustomSpacing(10, after: view)
        }
    }
}
