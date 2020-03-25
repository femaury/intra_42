//
//  UIImageViewRoundFrame.swift
//  Intra42
//
//  Created by Felix Maury on 2019-03-22.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class UIImageViewRounded: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()

        self.roundFrame()
    }
}

extension UIImageView {
    public func roundFrame() {
        layer.masksToBounds = true
        layer.cornerRadius = frame.width / 2
        clipsToBounds = true
    }
}
