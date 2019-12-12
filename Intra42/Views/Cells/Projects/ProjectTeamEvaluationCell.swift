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
    
    weak var delegate: UserProjectController?
    var correctorId: Int?
    
    func setupView(with evaluation: Evaluation) {
        correctorId = evaluation.corrector.id
        correctorName.setTitle(evaluation.corrector.login.uppercased(), for: .normal)
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = correctorPicture.convert(correctorPicture.center, from: correctorPicture.superview)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        correctorPicture.addSubview(activityIndicator)
        API42Manager.shared.getProfilePicture(withLogin: evaluation.corrector.login) { (image) in
            DispatchQueue.main.async {
                activityIndicator.stopAnimating()
                self.correctorPicture.image = image
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
                self.correctorPicture.addGestureRecognizer(tapGesture)
                self.correctorPicture.isUserInteractionEnabled = true
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
    
    @IBAction func showCorrectorProfile(_ sender: UIButton) {
        guard let id = correctorId else { return }
        delegate?.showCorrectorProfile(withId: id)
    }
    
    @objc func imageTapped(gesture: UIGestureRecognizer?) {
        guard let id = correctorId else { return }
        delegate?.showCorrectorProfile(withId: id)
    }
}
