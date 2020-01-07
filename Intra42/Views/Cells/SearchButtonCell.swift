//
//  SearchButtonCell.swift
//  Intra42
//
//  Created by Felix Maury on 07/01/2020.
//  Copyright © 2020 Felix Maury. All rights reserved.
//

import UIKit

class SearchButtonCell: UITableViewCell {

    weak var delegate: PeerFinderViewController?
    @IBOutlet weak var searchButton: UIButton!
    
    @IBAction func pressSearch(_ sender: Any) {
        
    }
}
