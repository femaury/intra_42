//
//  ClusterInfoView.swift
//  Intra42
//
//  Created by Felix Maury on 19/02/2020.
//  Copyright © 2020 Felix Maury. All rights reserved.
//

import UIKit

class ClusterInfoView: UIView {

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var friendsLabel: UILabel!
    
    @IBOutlet weak var outerProgressBar: UIView!
    @IBOutlet weak var innerProgressBar: UIView!
    @IBOutlet weak var progressLabel: UILabel!
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 400, height: 55))
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle(for: ClusterInfoView.self).loadNibNamed("ClusterInfo", owner: self, options: nil)
        contentView.fixInView(self)
    }
}
