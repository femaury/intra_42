//
//  ProjectTeamUsersCell.swift
//  Intra42
//
//  Created by Felix Maury on 2019-05-26.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class ProjectTeamUsersCell: UITableViewCell {

    @IBOutlet weak var userPicturesStack: UIStackView!
    
    func setupView(with users: [User]) {
        var index = 0
        var isLeader = true
        for case let picture as UIImageView in userPicturesStack.arrangedSubviews {
            if index < users.count {
                let user = users[index]
                API42Manager.shared.getProfilePicture(withLogin: user.login) { (image) in
                    DispatchQueue.main.async {
                        picture.isHidden = false
                        picture.image = image
                        picture.roundFrame()
                        if isLeader {
                            picture.layer.borderWidth = 2
                            picture.layer.borderColor = UIColor.orange.cgColor
                            isLeader = false
                        }
                    }
                }
            } else {
                picture.isHidden = true
            }
            index += 1
        }
    }
    
}
