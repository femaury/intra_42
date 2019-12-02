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
            profilePicture.layer.borderColor = Colors.validGrade?.cgColor
            profilePicture.layer.borderWidth = 2
            isOnline.isHidden = false
        }
    }
//    var campusId: Int! {
//        didSet {
//            campusLabel.isHidden = false
//            switch campusId {
//            case 0:
//                campusLabel.text = "
//            case 1:
//            case 2:
//            case 3:
//            case 4:
//            case 5:
//            case 6:
//            case 7:
//            case 8:
//            case 9:
//            case 10:
//            case 11:
//            case 12:
//            case 13:
//            case 14:
//            case 15:
//            case 16:
//            case 17:
//            case 18:
//            case 19:
//            case 20:
//            case 21:
//            case 22:
//            case 23:
//            case 24:
//            case 25:
//            case 26:
//            case 27:
//            case 28:
//            case 29:
//            case 30:
//            case 31:
//            default:
//                campusLabel.isHidden = true
//            }
//        }
//    }
}
