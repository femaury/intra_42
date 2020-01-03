//
//  FriendCell.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-03-06.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class FriendCell: UITableViewCell, UserProfileCell {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var onlineForLabel: UILabel!
    @IBOutlet weak var campusLabel: UILabel!
    @IBOutlet weak var isOnline: UIView!
    
    weak var delegate: FriendsViewController?
    var userId: Int = 0
    var indexPath: IndexPath = IndexPath()
    var friend: Friend?
    var info: FriendInfo?
    
    func setupCell(location: String) {
            
        if let friend = friend {
            let color = API42Manager.shared.preferedPrimaryColor
            usernameLabel.text = friend.username
            usernameLabel.textColor = color
            userId = friend.id
        }
        profilePicture.roundFrame()
        locationLabel.text = location
        self.isOnline.layer.cornerRadius = self.isOnline.frame.height / 2
        self.isOnline.clipsToBounds = true
        if location != "Unavailable" {
            campusLabel.isHidden = true
            onlineForLabel.isHidden = true
            profilePicture.layer.borderColor = UIColor.green.cgColor
            profilePicture.layer.borderWidth = 2
            isOnline.isHidden = false
            if let info = info {
                campusLabel.text = info.campus
                campusLabel.isHidden = false
                let time = info.online.getElapsedInterval().replacingOccurrences(of: " ago", with: "")
                onlineForLabel.text = "For \(time)"
                onlineForLabel.isHidden = false
            }
        } else {
            profilePicture.layer.borderColor = UIColor.black.cgColor
            profilePicture.layer.borderWidth = 1
            isOnline.isHidden = true
            onlineForLabel.isHidden = true
            campusLabel.isHidden = true
        }
    }
}
