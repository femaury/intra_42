//
//  SegmentTableViewCell.swift
//  Intra42
//
//  Created by Felix Maury on 08/01/2020.
//  Copyright © 2020 Felix Maury. All rights reserved.
//

import UIKit

class SegmentTableViewCell: UITableViewCell {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var segmentCallback: ((Int) -> Void)?
    
    @IBAction func changeSections(_ sender: UISegmentedControl) {
        guard let callback = segmentCallback else { return }
        callback(sender.selectedSegmentIndex)
    }
}
