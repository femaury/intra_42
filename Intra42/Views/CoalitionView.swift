//
//  CoalitionView.swift
//  Intra42
//
//  Created by Felix Maury on 2019-06-30.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class CoalitionView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var flagView: Pentagone!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var scoreLabel: AnimatedLabel!
    
    var score: Int = 0
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 480, height: 200))
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
        Bundle.main.loadNibNamed("Coalition", owner: self, options: nil)
        contentView.fixInView(self)
    }
}
