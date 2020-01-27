//
//  SegmentHeaderCell.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-03-03.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class SegmentHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var topLine: UIView!
    @IBOutlet weak var bottomLine: UIView!
    
    var segmentCallback: ((Int) -> Void)?
    
    @IBAction func changeSections(_ sender: UISegmentedControl) {
        guard let callback = segmentCallback else { return }
        callback(sender.selectedSegmentIndex)
    }
}
