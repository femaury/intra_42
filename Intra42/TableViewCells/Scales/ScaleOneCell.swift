//
//  ScaleOneCell.swift
//  Intra42
//
//  Created by Felix Maury on 2019-05-12.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class ScaleOneCell: UITableViewCell {

    @IBOutlet weak var projectLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var correctorImage: UIImageView!
    @IBOutlet weak var correctorNameLabel: UILabel!
    
    @IBOutlet weak var correcteeImage: UIImageView!
    @IBOutlet weak var correcteeNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        correctorImage.roundFrame()
        correctorImage.layer.borderWidth = 2
        correctorImage.layer.borderColor = WarningColor.orange?.cgColor
        
        correcteeImage.roundFrame()
        correcteeImage.layer.borderWidth = 2
        correcteeImage.layer.borderColor = WarningColor.green?.cgColor
    }
    
    func setupCell(correction: Correction) {
        projectLabel.text = correction.name
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd YYYY HH:mm"
        let dateString = formatter.string(from: correction.startDate)
        dateLabel.text = "\(dateString)"
        
        correctorNameLabel.text = correction.corrector.login
        if correction.corrector.login != "unknown" {
            API42Manager.shared.getProfilePicture(withLogin: correction.corrector.login) { [weak self] (image) in
                DispatchQueue.main.async {
                    self?.correctorImage.image = image
                }
            }
        }
        
        correcteeNameLabel.text = correction.correctees[0].login
        API42Manager.shared.getProfilePicture(withLogin: correction.correctees[0].login) { [weak self] (image) in
            DispatchQueue.main.async {
                self?.correcteeImage.image = image
            }
        }
    }

}
