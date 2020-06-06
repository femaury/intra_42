//
//  ProjectUserCell.swift
//  Intra42
//
//  Created by Felix Maury on 15/01/2020.
//  Copyright © 2020 Felix Maury. All rights reserved.
//

import UIKit

class ProjectUserCell: UITableViewCell, UserProfileCell {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var onlineView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var markedLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    
    var imageSession: URLSessionDataTask?
    var userId: Int = 0
    var user: ProjectUser? {
        didSet {
            guard let user = user else { return }
            userId = user.id
            
            let color = API42Manager.shared.preferedPrimaryColor
            loginLabel.text = user.login
            loginLabel.textColor = color
            
            profilePicture.roundFrame()
            let url = "https://cdn.intra.42.fr/users/small_\(user.login).jpg"
            imageSession = profilePicture.imageFrom(urlString: url, defaultImg: UIImage(named: "42_default"))
            
            onlineView.layer.cornerRadius = onlineView.frame.height / 2
            onlineView.clipsToBounds = true
            locationLabel.text = user.location
            if user.location != "Unavailable" {
                profilePicture.layer.borderColor = UIColor.green.cgColor
                profilePicture.layer.borderWidth = 2
                onlineView.isHidden = false
            } else {
                profilePicture.layer.borderColor = UIColor.black.cgColor
                profilePicture.layer.borderWidth = 1
                onlineView.isHidden = true
            }
            
            markedLabel.text = user.status.capitalized
            if user.marked {
                gradeLabel.text = String(user.grade ?? 0)
                gradeLabel.textColor = user.validated ? Colors.Grades.valid : UIColor.red
                gradeLabel.isHidden = false
            } else {
                gradeLabel.isHidden = true
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profilePicture?.image = nil
        imageSession?.cancel()
    }
}
