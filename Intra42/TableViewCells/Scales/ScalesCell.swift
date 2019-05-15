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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setupCell(correction: Correction) {
        projectLabel.text = correction.name
        
        var correctorName = correction.corrector.login
        var correcteeName = correction.correctees.count > 1 ? correction.teamName : correction.correctees.first?.login ?? "someone"
        
        if let me = API42Manager.shared.userProfile?.username {
            correctorName = correctorName.replacingOccurrences(of: me, with: "You")
            correcteeName = correcteeName.replacingOccurrences(of: me + "'s", with: "your")
            correcteeName = correcteeName.replacingOccurrences(of: me, with: "you")
        }
        
        if correctorName != "Someone" {
            correctorButton.titleLabel?.textColor = Colors.intraTeal
            correctorButton.isEnabled = true
        } else {
            correctorButton.titleLabel?.textColor = .lightGray
            correctorButton.isEnabled = false
        }
        
        if correcteeName != "someone" {
            correcteeButton.titleLabel?.textColor = Colors.intraTeal
            correcteeButton.isEnabled = true
        } else {
            correcteeButton.titleLabel?.textColor = .lightGray
            correcteeButton.isEnabled = false
        }
        
        correctorButton.titleLabel?.text = correctorName
        correcteeButton.titleLabel?.text = correcteeName
                
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, YYYY 'at' HH:mm"
        let dateString = formatter.string(from: correction.startDate)
        
        dateLabel.text = "\(dateString)"
        countdownLabel.text = correction.startDate.offset(from: Date())
    }
    
    @IBAction func onPressCorrector(_ sender: UIButton) {
        
    }
    
    @IBAction func onPressCorrectee(_ sender: UIButton) {
        
    }
}
