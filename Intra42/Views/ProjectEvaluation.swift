//
//  ProjectEvaluation.swift
//  Intra42
//
//  Created by Felix Maury on 2019-05-26.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class ProjectEvaluation: UIView {
    
    @IBOutlet var contentView: UIView!
    
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
    
//    weak var delegate: ProjectsViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ProjectEvaluation", owner: self, options: nil)
        contentView.fixInView(self)
    }
    
    func setup(evaluation: Evaluation) {
        correctorName.setTitle(evaluation.corrector.login.uppercased(), for: .normal)
        API42Manager.shared.getProfilePicture(withLogin: evaluation.corrector.login) { (image) in
            DispatchQueue.main.async {
                self.correctorPicture.image = image
            }
        }
        timeAgoLabel.text = evaluation.timeAgo.uppercased()
        gradeLabel.text = "\(evaluation.grade)%"
        if evaluation.isValidated {
            gradeLabel.textColor = Colors.Grades.valid
        } else {
            gradeLabel.textColor = UIColor.red
        }
        commentLabel.text = evaluation.comment
        feedbackLabel.text = evaluation.feedback
    }

    @IBAction func showCorrectorPage(_ sender: UIButton) {
    }
    
}
