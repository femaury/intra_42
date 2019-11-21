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
    @IBOutlet weak var isOnline: UIView! {
        didSet {
            isOnline.layer.cornerRadius = isOnline.frame.height / 2
            isOnline.clipsToBounds = true
        }
    }
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    
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
            if friend.phone == "hidden" {
                callButton.isEnabled = false
            } else {
                callButton.isEnabled = true
                callButton.tintColor = color
            }
            emailButton.tintColor = color
            userId = friend.id
        }
    }
    var location: String! {
        didSet {
            locationLabel.text = location
            profilePicture.layer.borderColor = Colors.validGrade?.cgColor
            profilePicture.layer.borderWidth = 2
            isOnline.isHidden = false
        }
    }
    
    @IBAction func callUser(_ sender: UIButton) {
        delegate?.callFriend(withId: userId, phone: friend.phone)
    }
    
    @IBAction func emailUser(_ sender: UIButton) {
        delegate?.emailFriend(withId: userId, email: friend.email)
    }
}
