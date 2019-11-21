//
//  SegmentHeaderCell.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-03-03.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class SegmentHeaderCell: UITableViewCell {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var topLine: UIView!
    @IBOutlet weak var bottomLine: UIView!
    
    var segmentCallback: ((Int) -> Void)?
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        if #available(iOS 13.0, *) {
//            segmentControl.selectedSegmentTintColor = segmentColor
//        } else {
//            segmentControl.tintColor = segmentColor
//        }
//    }
    
    @IBAction func changeSections(_ sender: UISegmentedControl) {
        guard let callback = segmentCallback else { return }
        callback(sender.selectedSegmentIndex)
    }
}
