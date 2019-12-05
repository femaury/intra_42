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
        var isLeader = true
        for case let picture as UIImageView in userPicturesStack.arrangedSubviews {
            if index < users.count {
                let user = users[index]
                API42Manager.shared.getProfilePicture(withLogin: user.login) { (image) in
                    DispatchQueue.main.async {
                        picture.isHidden = false
                        picture.image = image
                        picture.tag = user.id
                        picture.roundFrame()
                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
                        picture.addGestureRecognizer(tapGesture)
                        picture.isUserInteractionEnabled = true
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
    
    @objc func imageTapped(gesture: UIGestureRecognizer) {
        if let imageView = gesture.view as? UIImageView {
            delegate?.showCorrectorProfile(withId: imageView.tag)
        }
    }
}
