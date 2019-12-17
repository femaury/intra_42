//
//  ScalesCell.swift
//  Intra42
//
//  Created by Felix Maury on 2019-05-12.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class ScalesCell: UITableViewCell {

    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var rectangleView: UIView!
    @IBOutlet weak var triangleView: Triangle!
    @IBOutlet weak var dateView: UIView!
    
    @IBOutlet weak var projectLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!

    @IBOutlet weak var correctorButton: UIButton!
    @IBOutlet weak var correcteeButton: UIButton!
    
    private var correcteeTeamId: Int?
    private var correctorId: Int?
    private var projectId: Int?
    
    weak var delegate: CorrectionsViewController?
    
    func setupCell(correction: Correction, delegate del: CorrectionsViewController) {
        delegate = del
        correcteeTeamId = correction.team.id
        correctorId = correction.corrector.id
        projectId = correction.projectId
        
        let color = API42Manager.shared.preferedPrimaryColor
        lineView.backgroundColor = color
        rectangleView.backgroundColor = color
        triangleView.backgroundColor = color
        dateView.backgroundColor = color
        
        projectLabel.text = correction.name
        
        var correctorName = correction.corrector.login
        var correcteeName = correction.correctees.count > 1 ? correction.team.name : correction.correctees.first?.login ?? "someone"
        
        if let myLogin = API42Manager.shared.userProfile?.username {
            correctorName = correctorName.replacingOccurrences(of: myLogin, with: "You")
            correcteeName = correcteeName.replacingOccurrences(of: myLogin + "'s", with: "your")
            correcteeName = correcteeName.replacingOccurrences(of: myLogin, with: "you")
        }
        
        if correctorName == "Someone" {
            correctorButton.setTitleColor(.lightGray, for: .normal)
            correctorButton.isEnabled = false
        } else {
            correctorButton.setTitleColor(Colors.intraTeal, for: .normal)
            correctorButton.isEnabled = true
        }
        
        if correcteeName == "someone" {
            correcteeButton.setTitleColor(.lightGray, for: .normal)
            correcteeButton.isEnabled = false
        } else {
            correcteeButton.setTitleColor(Colors.intraTeal, for: .normal)
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
        delegate?.showCorrectorProfile(withId: id)
    }
    
    @IBAction func onPressCorrectee(_ sender: UIButton) {
        guard let id = correcteeTeamId, let name = projectLabel.text else { return }
        delegate?.showCorecteeTeamPage(teamId: id, projectName: name)
    }
}
