//
//  ScalesCell.swift
//  Intra42
//
//  Created by Felix Maury on 2019-05-12.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class ScalesCell: UITableViewCell {

    @IBOutlet weak var projectLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!

    @IBOutlet weak var correctorButton: UIButton!
    @IBOutlet weak var correcteeButton: UIButton!
    
    private var correcteeTeamId: Int?
    private var correctorId: Int?
    
    func setupCell(correction: Correction) {
        correcteeTeamId = correction.team.id
        correctorId = correction.corrector.id
        
        projectLabel.text = correction.name
        
        var correctorName = correction.corrector.login
        var correcteeName = correction.correctees.count > 1 ? correction.team.name : correction.correctees.first?.login ?? "someone"
        
        if let me = API42Manager.shared.userProfile?.username {
            correctorName = correctorName.replacingOccurrences(of: me, with: "You")
            correcteeName = correcteeName.replacingOccurrences(of: me + "'s", with: "your")
            correcteeName = correcteeName.replacingOccurrences(of: me, with: "you")
        }
        
        if correctorName == "Someone" {
            correctorButton.titleLabel?.textColor = .lightGray
            correctorButton.isEnabled = false
        } else {
            correctorButton.titleLabel?.textColor = Colors.intraTeal
            correctorButton.isEnabled = true
        }
        
        if correcteeName == "someone" {
            correcteeButton.titleLabel?.textColor = .lightGray
            correcteeButton.isEnabled = false
        } else {
            correcteeButton.titleLabel?.textColor = Colors.intraTeal
            correcteeButton.isEnabled = true
        }
        
        correctorButton.setTitle(correctorName, for: .normal)
        correcteeButton.setTitle(correcteeName, for: .normal)
                
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, YYYY 'at' HH:mm"
        let dateString = formatter.string(from: correction.startDate)
        
        dateLabel.text = "\(dateString)"
        countdownLabel.text = correction.startDate.offset(from: Date())
    }
    
    @IBAction func onPressCorrector(_ sender: UIButton) {
        guard let id = correctorId else { return }
        if id == API42Manager.shared.userProfile?.userId, let tbc = self.window?.rootViewController as? UITabBarController {
            tbc.selectedIndex = 1
        } else {
            // TODO: Use UserProfileDataSource to segue to user profile
        }
    }
    
    @IBAction func onPressCorrectee(_ sender: UIButton) {
        // TODO: Implement
    }
}
