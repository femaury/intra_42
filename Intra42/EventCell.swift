//
//  EventCell.swift
//  Intra42
//
//  Created by Felix Maury on 2019-03-09.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dateStack: UIStackView!
    @IBOutlet weak var dateDayLabel: UILabel!
    @IBOutlet weak var dateMonthLabel: UILabel!
    @IBOutlet weak var eventKindLabel: UILabel!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventTimeButton: UIButton!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var eventLocationButton: UIButton!
    @IBOutlet weak var eventLocationLabel: UILabel!
    
    var event: Event! {
        didSet {
            containerView.layer.borderWidth = 1
            containerView.layer.borderColor = event.color.reg?.cgColor
            
            dateView.backgroundColor = event.color.reg
            dateStack.setCustomSpacing(5.0, after: dateMonthLabel)
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.current
            
            dateFormatter.dateFormat = "d"
            dateDayLabel.text = dateFormatter.string(from: event.begin)
            
            dateFormatter.dateFormat = "MMMM"
            dateMonthLabel.text = dateFormatter.string(from: event.begin)
            
            eventKindLabel.text = event.kind.rawValue.capitalized
            eventNameLabel.text = event.name
            eventTimeButton.tintColor = event.color.reg
            eventTimeLabel.text = event.duration
            eventTimeLabel.textColor = event.color.reg
            eventLocationButton.tintColor = event.color.reg
            eventLocationLabel.text = event.location
            eventLocationLabel.textColor = event.color.reg
        }
    }
    
}
