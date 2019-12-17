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
                let activityIndicator = UIActivityIndicatorView()
                activityIndicator.center = picture.convert(picture.center, from: picture.superview)
                activityIndicator.hidesWhenStopped = true
                activityIndicator.startAnimating()
                picture.image = nil
                picture.addSubview(activityIndicator)
                picture.layer.borderWidth = 0
                if index == 0 {
                    picture.layer.borderWidth = 2
                    picture.layer.borderColor = UIColor.orange.cgColor
                }
                API42Manager.shared.getProfilePicture(withLogin: user.login) { (image) in
                    DispatchQueue.main.async {
                        activityIndicator.stopAnimating()
                        picture.image = image
                        picture.tag = user.id
                        picture.roundFrame()
                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
                        picture.addGestureRecognizer(tapGesture)
                        picture.isUserInteractionEnabled = true
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
