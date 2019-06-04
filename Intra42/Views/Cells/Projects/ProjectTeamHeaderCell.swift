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
    
    func setupView(_ teamName: String, _ grade: String, _ createdAgo: String, _ closedAgo: String) {
        teamNameLabel.text = teamName
        projectGradeLabel.text = grade
        createdAgoLabel.text = createdAgo
        closedAgoLabel.text = closedAgo
    }
}
