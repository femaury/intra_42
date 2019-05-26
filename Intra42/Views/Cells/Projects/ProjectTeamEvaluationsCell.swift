//
//  ProjectTeamEvaluationsCell.swift
//  Intra42
//
//  Created by Felix Maury on 2019-05-26.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class ProjectTeamEvaluationsCell: UITableViewCell {

    @IBOutlet weak var evaluationCountLabel: UILabel!
    @IBOutlet weak var evaluationsStack: UIStackView!
    
    func setupEvaluations(evaluations: [Evaluation]) {
        let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 100)
        let evaluation = Evaluation(correctorName: "femaury",
                                    timeAgo: "3 seconds ago",
                                    grade: "125%",
                                    isValid: true,
                                    comment: "Big memes",
                                    feedback: "No u")
        let projectEvaluation = ProjectEvaluation(frame: frame)
        projectEvaluation.setup(evaluation: evaluation)
        evaluationCountLabel.text = "(1/3)"
        evaluationsStack.addArrangedSubview(projectEvaluation)
        let projectEvaluation2 = ProjectEvaluation(frame: frame)
        projectEvaluation2.setup(evaluation: evaluation)
        evaluationsStack.addArrangedSubview(projectEvaluation2)
    }

}
