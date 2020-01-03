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
    weak var delegate: UserProjectController?
    
    func setupView(with users: [User]) {
        var index = 0
        for case let picture as UIImageView in userPicturesStack.arrangedSubviews {
            if index < users.count {
                let user = users[index]
                picture.layer.borderWidth = 0
                if index == 0 {
                    picture.layer.borderWidth = 2
                    picture.layer.borderColor = UIColor.orange.cgColor
                    picture.roundFrame()
                }
                let url = "https://cdn.intra.42.fr/users/small_\(user.login).jpg"
                picture.imageFrom(urlString: url, defaultImg: UIImage(named: "42_default"))
                picture.roundFrame()
                picture.tag = user.id
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
                picture.addGestureRecognizer(tapGesture)
                picture.isUserInteractionEnabled = true
            } else {
                picture.isHidden = true
            }
            index += 1
        }
    }
    
    @objc func imageTapped(gesture: UIGestureRecognizer) {
        if let imageView = gesture.view as? UIImageView {
            delegate?.showCorrectorProfile(withId: imageView.tag)
        }
    }
}
