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
    @IBOutlet weak var isOnline: UIView! {
        didSet {
            isOnline.layer.cornerRadius = isOnline.frame.height / 2
            isOnline.clipsToBounds = true
        }
    }
    let activityIndicator = UIActivityIndicatorView()
    
    weak var delegate: FriendsViewController?
    var userId: Int = 0
    var indexPath: IndexPath!
    var picture: UIImage? {
        didSet {
            profilePicture.image = picture
            profilePicture.roundFrame()
            profilePicture.layer.borderWidth = 1
            profilePicture.layer.borderColor = UIColor.black.cgColor
        }
    }
    var friend: Friend! {
        didSet {
            let color = API42Manager.shared.preferedPrimaryColor
            usernameLabel.text = friend.username
            usernameLabel.textColor = color
            userId = friend.id
        }
    }
    var location: String! {
        didSet {
            locationLabel.text = location
            profilePicture.layer.borderColor = UIColor.green.cgColor
            profilePicture.layer.borderWidth = 2
            isOnline.isHidden = false
        }
    }
}
