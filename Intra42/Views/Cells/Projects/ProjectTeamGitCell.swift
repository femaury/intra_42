//
//  ProjectTeamGitCell.swift
//  Intra42
//
//  Created by Felix Maury on 2019-05-26.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class ProjectTeamGitCell: UITableViewCell {

    @IBOutlet weak var repoLinkLabel: UILabel!
    @IBOutlet weak var copyLinkButton: UIButton!
    
    weak var delegate: UserProjectController?
    
    @IBAction func copyLink(_ sender: UIButton) {
        guard let delegate = delegate else { return }
        UIPasteboard.general.string = repoLinkLabel.text
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "NotificationView") as! NotificationViewController
        _ = controller.view // Force controller to load outlets
        controller.messageLabel.text = "Copied."
        controller.imageView.image = controller.imageView.image?.withRenderingMode(.alwaysTemplate)
        controller.providesPresentationContextTransitionStyle = true
        controller.definesPresentationContext = true
        controller.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        controller.modalTransitionStyle = .crossDissolve
        delegate.present(controller, animated: true, completion: nil)
    }
}
