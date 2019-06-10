//
//  ProjectTeamEvaluationCell.swift
//  Intra42
//
//  Created by Felix Maury on 2019-06-04.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class ProjectTeamEvaluationCell: UITableViewCell {
    
    @IBOutlet weak var correctorPicture: UIImageView! {
        didSet {
            correctorPicture.contentMode = .scaleAspectFill
            correctorPicture.roundFrame()
        }
    }
    @IBOutlet weak var correctorName: UIButton!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var feedbackLabel: UILabel!
    
    func setupView(with evaluation: Evaluation) {
        correctorName.setTitle(evaluation.corrector.login.uppercased(), for: .normal)
        API42Manager.shared.getProfilePicture(withLogin: evaluation.corrector.login) { (image) in
            DispatchQueue.main.async {
                self.correctorPicture.image = image
            }
        }
        timeAgoLabel.text = evaluation.timeAgo.uppercased()
        gradeLabel.text = "\(evaluation.grade)%"
        if evaluation.isValidated {
            gradeLabel.textColor = Colors.validGrade
        } else {
            gradeLabel.textColor = UIColor.red
        }
        commentLabel.text = evaluation.comment
        feedbackLabel.text = evaluation.feedback
    }
}
