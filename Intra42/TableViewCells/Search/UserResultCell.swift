//
//  UserResultCell.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-03-04.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class UserResultCell: UITableViewCell, UserProfileCell {

    @IBOutlet weak var userPicture: UIImageView! {
        didSet {
            userPicture.contentMode = .scaleAspectFill
            userPicture.roundFrame()
            userPicture.layer.borderWidth = 1
            userPicture.layer.borderColor = UIColor.black.cgColor
        }
    }
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addUserButton: UIButton!
    @IBOutlet weak var addUserIndicator: UIActivityIndicatorView!
    
    var userId: Int = 0
    weak var delegate: SearchResultsController?
    
    func setupAddUserButton(isFriend: Bool) {
        if isFriend {
            addUserButton.setImage(UIImage(named: "ok"), for: .normal)
            addUserButton.isUserInteractionEnabled = false
            addUserButton.tintColor = ValidGrade
        } else {
            addUserButton.setImage(UIImage(named: "add_user_male"), for: .normal)
            addUserButton.isUserInteractionEnabled = true
            addUserButton.tintColor = IntraTeal
        }
    }
    
    @IBAction func addUser(_ sender: UIButton) {
        guard let delegate = self.delegate else { return }
        let idString = String(userId)
        addUserButton.isUserInteractionEnabled = false
        addUserButton.setImage(nil, for: .normal)
        addUserIndicator.isHidden = false
        addUserIndicator.startAnimating()
        API42Manager.shared.request(url: "https://api.intra.42.fr/v2/users/\(idString)") { [weak self] (data) in
            guard let self = self, let data = data else { return }
            let username = data["login"].stringValue
            let id = data["id"].intValue
            let phone = data["phone"].stringValue
            let email = data["email"].stringValue
            let friend = Friend(id: id, username: username, phone: phone, email: email)
            delegate.addUser(friend: friend)
            self.addUserIndicator.stopAnimating()
            self.addUserButton.setImage(UIImage(named: "ok"), for: .normal)
            self.addUserButton.tintColor = ValidGrade
        }
    }
}