//
//  LoadingCell.swift
//  Intra42
//
//  Created by Felix Maury on 2019-11-22.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class LoadingCell: UITableViewCell {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            if #available(iOS 13.0, *) {
                activityIndicator.style = .large
            } else {
                activityIndicator.style = .gray
            }
        }
    }

}
