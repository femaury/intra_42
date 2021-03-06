//
//  ProjectTeamHeaderCell.swift
//  Intra42
//
//  Created by Felix Maury on 2019-05-26.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class ProjectTeamHeaderCell: UITableViewCell {

    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var projectGradeLabel: UILabel!
    @IBOutlet weak var createdAgoLabel: UILabel!
    @IBOutlet weak var closedAgoLabel: UILabel!
    
    func setupView(_ teamName: String, _ grade: String, _ isValidated: Bool, _ status: String, _ createdAgo: String, _ closedAgo: String) {
        teamNameLabel.text = teamName
        projectGradeLabel.text = grade
        projectGradeLabel.isHidden = false
        if status != "finished" {
            projectGradeLabel.isHidden = true
        }
        if isValidated {
            projectGradeLabel.textColor = Colors.Grades.valid
        } else {
            projectGradeLabel.textColor = .red
        }
        createdAgoLabel.text = createdAgo
        closedAgoLabel.text = closedAgo
    }
}
