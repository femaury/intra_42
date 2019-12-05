//
//  ProjectInfoViewController.swift
//  Intra42
//
//  Created by Felix Maury on 2019-12-03.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

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
    weak var delegate: HolyGraphViewController?
    
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
        if info.name.count > 20 {
            title = String(info.name.prefix(20)) + "..."
        } else {
            title = info.name
        }
        expLabel.text = "\(info.exp) XP"
        groupSizeLabel.text = info.groupSize
        durationLabel.text = info.duration
        gradeLabel.text = info.grade
        
        setState(info.state)
        
        gradeView.roundCorners(corners: .allCorners, radius: 5)
        descriptionText.text = info.description
        objectivesLabel.text = info.objectives.joined(separator: " / ")
        
        activityIndicator.stopAnimating()
    }
    
    func setState(_ state: ProjectState) {
        switch state {
        case .success:
            gradeView.backgroundColor = Colors.Grades.valid
            registerButton.title = "Retry"
            registerButton.tintColor = Colors.intraTeal
        case .fail:
            gradeView.backgroundColor = Colors.Grades.fail
            registerButton.title = "Retry"
            registerButton.tintColor = Colors.intraTeal
        case .unavailable:
            gradeView.isHidden = true
            registerButton.title = "Register"
            registerButton.isEnabled = false
        case .available:
            gradeView.isHidden = true
            registerButton.title = "Register"
            registerButton.tintColor = Colors.intraTeal
        case .inProgress:
            gradeView.isHidden = true
            registerButton.title = "Unregister"
            registerButton.tintColor = .red
        }
    }
    
    func notifySubscription(with message: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "NotificationView") as! NotificationViewController
        _ = controller.view // Force controller to load outlets
        controller.messageLabel.text = message
        controller.imageView.image = controller.imageView.image?.withRenderingMode(.alwaysTemplate)
        controller.providesPresentationContextTransitionStyle = true
        controller.definesPresentationContext = true
        controller.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        controller.modalTransitionStyle = .crossDissolve
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func pressRegister(_ sender: Any) {
        guard let state = info?.state, let id = info?.id else { return }
        var method: HTTPMethod
        var notifyMsg: String
        var errorMsg: String
        var alertBtn: String
        var alertStyle: UIAlertAction.Style
        var newState: ProjectState
        
        switch state {
        case .success, .fail:
            method = .patch
            notifyMsg = "Retried."
            errorMsg = "There was an error retrying the project..."
            alertBtn = "Retry"
            alertStyle = .destructive
            newState = .inProgress // TODO: Verify if it actually changes state or not... Any testers in chat?
        case .inProgress:
            method = .delete
            notifyMsg = "Unregistered."
            errorMsg = "There was an error unregistering from the project..."
            alertBtn = "Unregister"
            alertStyle = .destructive
            newState = .available
        case .available:
            method = .post
            notifyMsg = "Registered!"
            errorMsg = "There was an error registering to the project..."
            alertBtn = "Register"
            alertStyle = .default
            newState = .inProgress
        default:
            return
        }
        let alert = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: alertBtn, style: alertStyle) { _ in
            API42Manager.shared.modifyProject(withId: id, method: method) { [weak self] success in
                if success {
                    self?.info?.state = newState
                    self?.setState(newState)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                         // TODO: Manually change state instead of delaying call
                        self?.delegate?.reloadHolyGraph()
                    }
                    self?.notifySubscription(with: notifyMsg)
                } else {
                    API42Manager.shared.showErrorAlert(message: errorMsg)
                }
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
}
