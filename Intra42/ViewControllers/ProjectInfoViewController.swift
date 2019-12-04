//
//  ProjectInfoViewController.swift
//  Intra42
//
//  Created by Felix Maury on 2019-12-03.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

enum ProjectState: String {
    case success = "done"
    case fail = "fail"
    case inProgress = "in_progress"
    case available = "available"
    case unavailable = "unavailable"
}

struct ProjectInfo {
    var id: Int
    var name: String
    var exp: Int
    var groupSize: String
    var duration: String
    var state: ProjectState
    var grade: String
    var description: String
    var objectives: [String]
}

class ProjectInfoViewController: UIViewController {

    @IBOutlet weak var expLabel: UILabel!
    @IBOutlet weak var groupSizeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var gradeView: UIView!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var objectivesLabel: UILabel!
    @IBOutlet weak var registerButton: UIBarButtonItem!
    
    var info: ProjectInfo?
    let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        activityIndicator.frame = view.frame
        activityIndicator.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            activityIndicator.style = .large
            activityIndicator.backgroundColor = .systemBackground
        } else {
            activityIndicator.backgroundColor = .white
        }
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    func setupController() {
        guard let info = self.info else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        title = info.name
        expLabel.text = "\(info.exp) XP"
        groupSizeLabel.text = info.groupSize
        durationLabel.text = info.duration
        gradeLabel.text = info.grade
        
        switch info.state {
        case .success:
            gradeView.backgroundColor = Colors.Grades.valid
            registerButton.isEnabled = false
        case .fail:
            gradeView.backgroundColor = Colors.Grades.fail
            registerButton.title = "Retry"
            registerButton.tintColor = .red
        case .unavailable:
            gradeView.isHidden = true
            registerButton.isEnabled = false
        case .available:
            gradeView.isHidden = true
        case .inProgress:
            gradeView.isHidden = true
            registerButton.title = "Unregister"
            registerButton.tintColor = .red
        }
        gradeView.roundCorners(corners: .allCorners, radius: 5)
        descriptionText.text = info.description
        objectivesLabel.text = info.objectives.joined(separator: " / ")
        
        activityIndicator.stopAnimating()
    }
    
    @IBAction func pressRegister(_ sender: Any) {
    }
}
