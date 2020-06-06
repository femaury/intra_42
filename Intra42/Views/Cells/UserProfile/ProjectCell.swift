//
//  ProjectCell.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-03-03.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class ProjectCell: UITableViewCell {

    @IBOutlet weak var projectNameBtn: UIButton!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    
    @IBAction func clickOnProjectName(_ sender: UIButton) {
        // - TODO: Add segue to project info page
    }
}
